import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                if let user = authViewModel.currentUser {
                    Section(header: Text("Account")) {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email ?? "")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: { authViewModel.signOut() }) {
                        HStack {
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
} 