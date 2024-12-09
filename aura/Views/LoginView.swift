import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var animateGradient = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    colors: [
                        AuraTheme.primary.opacity(0.8),
                        AuraTheme.accent.opacity(0.6)
                    ],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Logo and Welcome Text
                        VStack(spacing: 16) {
                            AuraLogo(size: 48)
                            
                            Text("Welcome to fiora")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(isSignUp ? "Create an account to start your hair journey" : "Sign in to continue your hair journey")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 60)
                        
                        // Login/Signup Form
                        VStack(spacing: 24) {
                            VStack(spacing: 20) {
                                if isSignUp {
                                    CustomTextField(
                                        text: $name,
                                        placeholder: "Full Name",
                                        icon: "person.fill"
                                    )
                                    .frame(height: 56)
                                    .textContentType(.name)
                                }
                                
                                CustomTextField(
                                    text: $email,
                                    placeholder: "Email",
                                    icon: "envelope.fill"
                                )
                                .frame(height: 56)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                
                                CustomTextField(
                                    text: $password,
                                    placeholder: "Password",
                                    icon: "lock.fill",
                                    isSecure: true
                                )
                                .frame(height: 56)
                                .textContentType(isSignUp ? .newPassword : .password)
                            }
                            
                            if let error = authViewModel.alertItem?.message {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                            }
                            
                            Button(action: {
                                if isSignUp {
                                    authViewModel.signUp(email: email, password: password, name: name)
                                } else {
                                    authViewModel.signIn(email: email, password: password)
                                }
                            }) {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text(isSignUp ? "Create Account" : "Sign In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AuraTheme.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(28)
                                .shadow(color: AuraTheme.primary.opacity(0.3), radius: 8, y: 4)
                            }
                            .disabled(authViewModel.isLoading || (isSignUp && name.isEmpty) || email.isEmpty || password.isEmpty)
                            
                            Button(action: { withAnimation { isSignUp.toggle() }}) {
                                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                            }
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.2), radius: 16)
                        )
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

// Custom TextField component for consistent styling
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
} 