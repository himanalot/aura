import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("privacyMode") private var privacyMode = false
    @AppStorage("reminderFrequency") private var reminderFrequency = "Weekly"
    
    private let reminderOptions = ["Daily", "Weekly", "Monthly"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Privacy & Security") {
                    Toggle("Enhanced Privacy Mode", isOn: $privacyMode)
                        .foregroundColor(.primary)
                }
                
                Section("Notifications") {
                    Toggle("Progress Reminders", isOn: $notificationsEnabled)
                    if notificationsEnabled {
                        Picker("Reminder Frequency", selection: $reminderFrequency) {
                            ForEach(reminderOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                    }
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    
                    NavigationLink("Terms of Service") {
                        TermsOfServiceView()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
} 