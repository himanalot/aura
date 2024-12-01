import SwiftUI
import FirebaseAuth

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var showDiagnostic = false
    @Published var currentUser: User?
    @Published var alertItem: AlertItem?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.currentUser = user
            if user == nil {
                self.isSignedIn = false
                self.showDiagnostic = false
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                await MainActor.run {
                    self.currentUser = authResult.user
                }
                
                // First set signed in to true
                await MainActor.run {
                    self.isSignedIn = true
                }
                
                // Then check for diagnostic results
                if let _ = try? await FirebaseService.shared.fetchLatestDiagnosticResults(userId: authResult.user.uid) {
                    // User has completed diagnostic
                    await MainActor.run {
                        self.showDiagnostic = false
                    }
                } else {
                    // User hasn't completed diagnostic
                    await MainActor.run {
                        self.showDiagnostic = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.alertItem = AlertItem(
                        title: "Sign In Error",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.alertItem = AlertItem(
                    title: "Sign Up Error",
                    message: error.localizedDescription
                )
            } else {
                self?.isSignedIn = false
                self?.showDiagnostic = true
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    func deleteAccount() {
        Auth.auth().currentUser?.delete { [weak self] error in
            if let error = error {
                self?.alertItem = AlertItem(
                    title: "Delete Account Error",
                    message: error.localizedDescription
                )
            }
        }
    }
} 