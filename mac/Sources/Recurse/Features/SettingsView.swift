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
        }
        .frame(width: 500)
        .onAppear {
            if !loaded { s = store.settings(); loaded = true }
            // don't open with the name field focused and its text selected
            DispatchQueue.main.async { NSApp.keyWindow?.makeFirstResponder(nil) }
        }
        .onChange(of: s) { _, new in
            guard loaded else { return }
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
                    Avatar(size: 44).padding(2).overlay(Circle().strokeBorder(.white.opacity(0.14)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(s.username.isEmpty ? "You" : s.username).font(.headline)
                        Text("Level \(me.level.level) · \(me.level.title) · \(me.xp) XP").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                TextField("Name", text: $s.username, prompt: Text("Your name"))
            } footer: {
                Text("Shown in the greeting on Today.").font(.caption).foregroundStyle(.secondary)
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
        .formStyle(.grouped)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
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
        .formStyle(.grouped)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
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
