// ⌘, window. Port of pages/settings.tsx (+ notify-controls), with native notifications and open at login.
import SwiftUI

struct SettingsView: View {
    @Environment(Store.self) private var store
    @Environment(Reminders.self) private var reminders
    @State private var s = Settings()
    @State private var loaded = false
    @State private var atLogin = Reminders.openAtLogin
    @State private var permission = ""

    private static let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        Form {
            Section {
                TextField("Username", text: $s.username)
                Text("Shown in greetings.").font(.caption).foregroundStyle(.secondary)
            }
            Section("Study days") {
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { d in
                        Toggle(Self.days[d], isOn: Binding(
                            get: { s.plannedDays.contains(d) },
                            set: { on in if on { s.plannedDays.append(d) } else { s.plannedDays.removeAll { $0 == d } } }))
                            .toggleStyle(.button)
                    }
                }
                Text("Nudges come on these days. Other days only get a couple, and only while the week can still hit 5 goal days.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Reminders") {
                Toggle("Daily reminders", isOn: $s.reminders)
                HStack {
                    timeField("From", \.start)
                    timeField("Until", \.end)
                }
                .disabled(!s.reminders)
                Toggle("Open Recurse at login", isOn: $atLogin)
                    .onChange(of: atLogin) { _, on in Reminders.openAtLogin = on; atLogin = Reminders.openAtLogin }
                Text("Reminders need Recurse running. Closing the window keeps it in the Dock; quit it (⌘Q) to stop them.")
                    .font(.caption).foregroundStyle(.secondary)
                HStack {
                    Button("Send a test") {
                        Task {
                            permission = await reminders.requestPermission() ? "" : "Notifications are off for Recurse in System Settings."
                            reminders.sendTest()
                        }
                    }
                    Button("Snooze 1 hour") { reminders.snooze() }.disabled(!s.reminders)
                    Spacer()
                    Text(reminders.nextAt.map { "Next: \($0.formatted(date: .omitted, time: .shortened))" } ?? (s.reminders ? "Nothing more today" : "Off"))
                        .font(.caption).foregroundStyle(.secondary)
                }
                if !permission.isEmpty { Text(permission).font(.caption).foregroundStyle(.red) }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .onAppear {
            if !loaded { s = store.settings(); loaded = true }
        }
        .onChange(of: s) { _, new in
            guard loaded else { return }
            store.saveSettings(new)
            if new.reminders { Task { _ = await reminders.requestPermission() } }
            reminders.schedule()
        }
    }

    /// "HH:MM" strings, like the web settings table.
    private func timeField(_ label: String, _ key: WritableKeyPath<Settings.Window, String>) -> some View {
        DatePicker(label, selection: Binding(
            get: { ReminderTiming.at(.now, s.window[keyPath: key]) },
            set: { d in
                let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                s.window[keyPath: key] = String(format: "%02d:%02d", c.hour!, c.minute!)
            }), displayedComponents: .hourAndMinute)
    }
}
