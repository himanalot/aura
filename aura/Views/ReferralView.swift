import SwiftUI
import FirebaseAuth

struct ReferralView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var referralCode = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    let onSuccess: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Enter Friend's Referral Code")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    Text("Help a friend unlock their free analysis by using their referral code!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter Referral Code", text: $referralCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.characters)
                        .font(.system(.body, design: .monospaced))
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: submitReferralCode) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Submit")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || referralCode.isEmpty)
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submitReferralCode() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await FirebaseService.shared.useReferralCode(referralCode.uppercased(), by: userId)
                await MainActor.run {
                    onSuccess()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
} 