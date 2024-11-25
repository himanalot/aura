import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var selectedIndustries = Set<String>()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("Industry Preferences") {
                    ForEach(Industry.mockData) { industry in
                        Toggle(industry.name, isOn: binding(for: industry.name))
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func binding(for industry: String) -> Binding<Bool> {
        Binding(
            get: { selectedIndustries.contains(industry) },
            set: { isSelected in
                if isSelected {
                    selectedIndustries.insert(industry)
                } else {
                    selectedIndustries.remove(industry)
                }
            }
        )
    }
} 