import SwiftUI
import FirebaseAuth

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUser: User?
    @Published var alertItem: AlertItem?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isSignedIn = user != nil
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.alertItem = AlertItem(
                    title: "Sign In Error",
                    message: error.localizedDescription
                )
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
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
} 