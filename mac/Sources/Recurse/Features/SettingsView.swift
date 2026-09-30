import SwiftUI

struct SettingsView: View {
    @Environment(Store.self) private var store
    @Environment(Reminders.self) private var reminders
    @State private var s = Settings()
    @State private var loaded = false
    @State private var atLogin = Reminders.openAtLogin
    @AppStorage("menuBar") private var menuBar = true
    @State private var permission = ""

    private static let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    @AppStorage("settingsTab") private var tab = "general"

    var body: some View {
        TabView(selection: $tab) {
            Tab("General", systemImage: "gearshape", value: "general") { general }
            Tab("Reminders", systemImage: "bell.badge", value: "reminders") { remindersTab }
            Tab("Rewards", systemImage: "gift", value: "rewards") { RewardsTab() }
            Tab("AI", systemImage: "sparkles", value: "ai") { AITab() }
            Tab("Data", systemImage: "externaldrive", value: "data") { DataTab { s = store.settings() } }
            Tab("Updates", systemImage: "arrow.down.circle", value: "updates") { UpdatesTab() }
        }
        .frame(width: 500)
        .onAppear {
            if !loaded { s = store.settings(); loaded = true }
            // don't open with the name field focused and its text selected
            DispatchQueue.main.async { NSApp.keyWindow?.makeFirstResponder(nil) }
        }
        .onChange(of: s) { _, new in
            guard loaded else { return }
            var new = new
            let saved = store.settings()
            if new.name.trimmingCharacters(in: .whitespaces).isEmpty { new.name = saved.name } // the name can't be cleared
            if new.username.isEmpty { new.username = saved.username }
            store.saveSettings(new)
            if new.reminders { Task { _ = await reminders.requestPermission() } }
            reminders.schedule()
        }
    }

    private var general: some View {
        let me = store.me()
        return Form {
            Section {
                HStack(spacing: 14) {
                    Avatar(size: 44, image: s.avatar).padding(2).overlay(Circle().strokeBorder(.white.opacity(0.14)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(s.name.isEmpty ? "You" : s.name).font(.headline)
                        Text("Level \(me.level.level) · \(me.level.title) · \(me.xp) XP").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    PhotoButtons(avatar: $s.avatar)
                }
                .padding(.vertical, 4)
                TextField("Name", text: $s.name, prompt: Text("Your name"))
                TextField("Username", text: Binding(get: { s.username }, set: { s.username = Settings.clean($0) }), prompt: Text("username"))
            }

            Section {
                LabeledContent("Study days") {
                    HStack(spacing: 5) {
                        ForEach(0..<7, id: \.self) { d in DayChip(label: Self.days[d], on: dayBinding(d)) }
                    }
                }
            } footer: {
                Text("Reminders come on these days. Other days only get a couple, and only while the week can still hit 5 goal days.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section {
                Toggle("Open Recurse at login", isOn: $atLogin)
                    .onChange(of: atLogin) { _, on in Reminders.openAtLogin = on; atLogin = Reminders.openAtLogin }
                Toggle("Show in the menu bar", isOn: $menuBar)
            } footer: {
                Text("Reminders only fire while Recurse is running. Closing the window keeps it in the Dock; quit it (⌘Q) to stop them.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .settingsPane()
    }

    private var remindersTab: some View {
        Form {
            Section {
                Toggle("Daily reminders", isOn: $s.reminders)
                LabeledContent("Between") {
                    HStack(spacing: 8) {
                        timeField("From", \.start)
                        Text("and").foregroundStyle(.secondary)
                        timeField("Until", \.end)
                    }
                    .labelsHidden()
                }
                .disabled(!s.reminders)
                LabeledContent("Next reminder") {
                    Text(reminders.nextAt.map { $0.formatted(date: .omitted, time: .shortened) } ?? (s.reminders ? "Nothing more today" : "Off"))
                        .monospacedDigit()
                }
            } footer: {
                Text("A few nudges spread across your study days, never outside these hours.").font(.caption).foregroundStyle(.secondary)
            }

            Section {
                HStack {
                    Button("Send a Test") {
                        Task {
                            permission = await reminders.requestPermission() ? "" : "Notifications are off for Recurse in System Settings."
                            reminders.sendTest()
                        }
                    }
                    Button("Snooze 1 Hour") { reminders.snooze() }.disabled(!s.reminders)
                    Spacer()
                }
                .buttonBorderShape(.capsule)
                if !permission.isEmpty {
                    Label(permission, systemImage: "exclamationmark.triangle.fill").font(.callout).foregroundStyle(.danger)
                }
            }
        }
        .settingsPane()
    }

    private func dayBinding(_ d: Int) -> Binding<Bool> {
        Binding(get: { s.plannedDays.contains(d) },
                set: { on in if on { s.plannedDays.append(d); s.plannedDays.sort() } else { s.plannedDays.removeAll { $0 == d } } })
    }

    /// Stored as "HH:MM" strings.
    private func timeField(_ label: String, _ key: WritableKeyPath<Settings.Window, String>) -> some View {
        DatePicker(label, selection: Binding(
            get: { ReminderTiming.at(.now, s.window[keyPath: key]) },
            set: { d in
                let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                s.window[keyPath: key] = String(format: "%02d:%02d", c.hour!, c.minute!)
            }), displayedComponents: .hourAndMinute)
    }
}

private struct DayChip: View {
    let label: String
    @Binding var on: Bool

    var body: some View {
        Button { withAnimation(.snappy(duration: 0.2)) { on.toggle() } } label: {
            Text(label.prefix(1)).font(.callout.weight(.semibold))
                .foregroundStyle(on ? Color.brandInk : Color.secondary)
                .frame(width: 28, height: 28)
                .background(Circle().fill(on ? Color.brand : Color.raised))
                .overlay(Circle().strokeBorder(on ? .clear : Color.hairline))
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .help(label)
        .accessibilityLabel(label)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

private struct DataTab: View {
    @Environment(Store.self) private var store
    @Environment(Reminders.self) private var reminders
    let restored: () -> Void
    @State private var confirm: URL?
    @State private var status = ""

    var body: some View {
        Form {
            Section {
                LabeledContent("Back up everything") {
                    Button("Export…") { export() }
                }
                LabeledContent("Restore a backup") {
                    Button("Import…") {
                        let panel = NSOpenPanel()
                        panel.allowedContentTypes = [.data]
                        if panel.runModal() == .OK { confirm = panel.url }
                    }
                }
            } footer: {
                Text("A backup is one file with all your progress, settings and photo. Importing replaces what's here; the current data is saved to Backups first.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section {
                LabeledContent("Stored in") {
                    Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([Paths.db]) }
                }
                if !status.isEmpty { Text(status).font(.callout).foregroundStyle(.secondary) }
            } footer: {
                Text("Your data lives outside the app, so updating or reinstalling Recurse keeps it.").font(.caption).foregroundStyle(.secondary)
            }
        }
        .settingsPane()
        .alert("Replace your data with this backup?", isPresented: Binding(get: { confirm != nil }, set: { if !$0 { confirm = nil } })) {
            Button("Replace", role: .destructive) { if let url = confirm { restore(url) } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current progress is saved to Backups first, so you can undo this by importing that file.")
        }
    }

    private func export() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Recurse Backup \(Dates.local()).recurse"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try store.exportData(to: url)
            status = "Exported to \(url.lastPathComponent)."
        } catch { status = error.localizedDescription }
    }

    private func restore(_ url: URL) {
        do {
            try store.importData(from: url)
            reminders.schedule()
            restored()
            status = "Restored from \(url.lastPathComponent)."
        } catch { status = error.localizedDescription }
    }
}

private struct AITab: View {
    @Environment(Store.self) private var store
    @State private var config = AI.Config()
    @State private var loaded = false
    @State private var key = ""
    @State private var saved: String? // the stored key, shown only as its last 4 characters
    @State private var cli: String?? // nil until checked; .some(nil) = not found
    @State private var test: (ok: Bool, text: String)?
    @State private var testing = false

    var body: some View {
        let p = config.provider
        Form {
            Section {
                Picker("Provider", selection: $config.provider) {
                    ForEach(AIProvider.allCases) { Text($0.title).tag($0) }
                }
                if p.usesKey {
                    LabeledContent("API key") {
                        if let saved {
                            HStack(spacing: 8) {
                                Label("•••• \(saved.suffix(4))", systemImage: "lock.fill").foregroundStyle(.secondary)
                                Button("Remove") { Keychain.delete(p.rawValue); load() }
                            }
                        } else {
                            HStack(spacing: 8) {
                                SecureField("", text: $key, prompt: Text("Paste your key")).frame(width: 190)
                                Button("Save") { saveKey() }.disabled(key.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                    }
                } else {
                    LabeledContent("Claude Code") {
                        switch cli {
                        case .none: ProgressView().controlSize(.small)
                        case .some(.some): Label("Installed", systemImage: "checkmark.circle.fill").foregroundStyle(.success)
                        case .some(.none): Link("Install Claude Code", destination: URL(string: "https://claude.com/claude-code")!)
                        }
                    }
                }
                TextField("Model", text: $config.model, prompt: Text(p.defaultModel(.grade)))
            } footer: {
                let (grade, tutor) = (p.defaultModel(.grade), p.defaultModel(.tutor))
                Text(LocalizedStringKey((p.usesKey
                    ? "Your key is kept in the macOS Keychain, never in Recurse's database or backups. [Get a key](\(p.keyPage!))."
                    : "Uses your Claude Pro or Max plan through Claude Code. Run `claude` in Terminal once to log in.")
                    + (grade == tutor ? " Leave Model empty to use \(grade)." : " Leave Model empty to use \(grade) for grading and \(tutor) for the tutor.")))
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section {
                HStack(spacing: 10) {
                    Button("Test Connection") { runTest() }.disabled(testing || (p.usesKey && saved == nil))
                    if testing { ProgressView().controlSize(.small) }
                    if let test {
                        Label(test.text, systemImage: test.ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(test.ok ? Color.success : Color.danger).lineLimit(2)
                    }
                    Spacer()
                }
            } footer: {
                Text("AI grades your explanations and runs the Socratic tutor. Everything else works without it.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .settingsPane()
        .onAppear {
            if !loaded { config = store.aiConfig(); loaded = true }
            load()
        }
        .onReceive(NotificationCenter.default.publisher(for: .testAI)) { _ in runTest() }
        .onChange(of: config) { old, new in
            guard loaded else { return }
            store.putSetting("ai", new)
            if old.provider != new.provider { load() }
        }
    }

    private func load() {
        DispatchQueue.main.async { NSApp.keyWindow?.makeFirstResponder(nil) } // no key field focused, and no Passwords popup
        key = ""
        test = nil
        saved = config.provider.usesKey ? Keychain.get(config.provider.rawValue) : nil
        if !config.provider.usesKey { Task { cli = .some(await AI.claudePath()) } }
    }

    private func saveKey() {
        let k = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Keychain.set(config.provider.rawValue, k) else { test = (false, "Couldn't save to the Keychain."); return }
        load()
        runTest()
    }

    private func runTest() {
        testing = true
        test = nil
        Task {
            do {
                _ = try await AI.ask("Reply with just the word OK.", config, .tutor)
                test = (true, "Connected to \(config.model(.tutor))")
            } catch { test = (false, error.localizedDescription) }
            testing = false
        }
    }
}

private struct UpdatesTab: View {
    @State private var latest: Updates.Release?
    @State private var checking = false
    @State private var downloading = false
    @State private var error: String?

    var body: some View {
        let current = Updates.current
        let newer = latest.flatMap { l in current.map { Updates.isNewer(l.version, than: $0) } ?? false } ?? false
        Form {
            Section {
                HStack(spacing: 12) {
                    Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 36, height: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(newer ? "Recurse \(latest?.version ?? "") is available" : "Recurse \(current ?? "")")
                        status(newer: newer).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if downloading || checking { ProgressView().controlSize(.small) }
                    if newer {
                        Button("Update Now") { install() }.buttonStyle(.borderedProminent).disabled(downloading)
                    } else {
                        Button("Check Now") { check() }.disabled(checking || downloading)
                    }
                }
                .padding(.vertical, 2)
            } footer: {
                Text(LocalizedStringKey("Your progress is kept across updates. Release notes and downloads are [on GitHub](\(Updates.releasesPage.absoluteString))."))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .settingsPane()
        .task { if latest == nil { check() } }
    }

    @ViewBuilder private func status(newer: Bool) -> some View {
        if downloading, let latest { Text("Downloading \(latest.version)…") }
        else if checking { Text("Checking for updates…") }
        else if let error { Text(error) }
        else if Updates.current == nil { Text("Development build") }
        else if newer, let current = Updates.current { Text("You have \(current)") }
        else if latest != nil { Text("Up to date") }
    }

    private func check() {
        checking = true
        error = nil
        Task {
            do { latest = try await Updates.latest() } catch { self.error = error.localizedDescription }
            checking = false
        }
    }

    private func install() {
        guard let latest else { return }
        downloading = true
        error = nil
        Task {
            do { try await Updates.install(latest) } catch { self.error = error.localizedDescription }
            downloading = false
        }
    }
}

private struct RewardsTab: View {
    @Environment(Store.self) private var store
    @State private var editing: RewardState?

    var body: some View {
        Form {
            Section {
                ForEach(store.rewardPath()) { x in
                    HStack(spacing: 12) {
                        ArtImage(name: x.item.icon, size: 34)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(x.item.title).lineLimit(1)
                            Text(x.def.label).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Button("Edit") { editing = x }
                    }
                }
            } footer: {
                Text("Each milestone unlocks a real treat. Pick one, or add your own; choose the last one early so it's there to work towards.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(height: 540)
        .sheet(item: $editing) { RewardEditor(x: $0) }
    }
}

private struct RewardEditor: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    let x: RewardState
    @State private var item: RewardItem

    init(x: RewardState) {
        self.x = x
        _item = State(initialValue: x.item)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Reward for \(x.def.label)").font(.title3.weight(.semibold))
                Text("Pick something, or add your own. Choose it now so it's there to work towards.").font(.callout).foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
                ForEach(RewardItem.presets, id: \.icon) { p in tile(p.icon, p.title) { item = p } }
                tile("custom", "Your own") { if item.icon != "custom" { item = RewardItem(title: "") } }
            }
            VStack(alignment: .leading, spacing: 10) {
                TextField("Title", text: $item.title, prompt: Text("What you'll get"))
                TextField("Note", text: $item.note, prompt: Text("A line to keep you going (optional)"))
            }
            .textFieldStyle(.roundedBorder)
            HStack {
                Button("Reset to Default") {
                    store.setReward(x.id, nil)
                    dismiss()
                }
                .disabled(!x.custom)
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }.keyboardShortcut(.cancelAction)
                Button("Save") {
                    store.setReward(x.id, item == x.def.item ? nil : item)
                    dismiss()
                }
                .buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction)
                .disabled(item.title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 480)
    }

    private func tile(_ icon: String, _ title: String, pick: @escaping () -> Void) -> some View {
        let on = item.icon == icon
        return Button(action: pick) {
            VStack(spacing: 6) {
                ArtImage(name: icon, size: 44)
                Text(title).font(.caption).lineLimit(1).foregroundStyle(on ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(on ? Color.brand.opacity(0.12) : Color.raised.opacity(0.5), in: .rect(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(on ? Color.brand.opacity(0.6) : Color.hairline))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

private extension View {
    func settingsPane() -> some View {
        formStyle(.grouped).scrollDisabled(true).fixedSize(horizontal: false, vertical: true)
    }
}

extension Notification.Name {
    /// Posted by DevSnapshots to press Test Connection.
    static let testAI = Notification.Name("RecurseTestAI")
}
