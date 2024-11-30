import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showDeleteConfirmation = false
    
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
                    
                    Button(action: { showDeleteConfirmation = true }) {
                        HStack {
                            Text("Delete Account")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    authViewModel.deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
} 