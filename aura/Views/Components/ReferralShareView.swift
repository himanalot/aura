import SwiftUI
import FirebaseAuth

struct ReferralShareView: View {
    @Environment(\.dismiss) private var dismiss
    let referralCode: ReferralCode
    let onDismiss: () -> Void
    @State private var codeCopied = false
    @State private var isGeneratingCode = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Share Your Referral Code")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    Text("Share this code with 2 different friends to unlock your free analysis!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text(referralCode.code)
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    
                    Text("\(referralCode.usedBy.count)/2 friends have used your code")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    
                    if referralCode.usedBy.count >= 2 {
                        Text("Code fully used! Generate a new code to share!")
                            .foregroundColor(.green)
                            .font(.headline)
                    }
                }
                
                if referralCode.usedBy.count >= 2 {
                    Button(action: generateNewCode) {
                        if isGeneratingCode {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Generate New Code")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isGeneratingCode)
                } else {
                    Button(action: {
                        UIPasteboard.general.string = referralCode.code
                        codeCopied = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            codeCopied = false
                        }
                    }) {
                        HStack {
                            Image(systemName: codeCopied ? "checkmark" : "doc.on.doc")
                            Text(codeCopied ? "Copied!" : "Copy Code")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private func generateNewCode() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isGeneratingCode = true
        
        Task {
            do {
                _ = try await FirebaseService.shared.generateReferralCode(for: userId)
                await MainActor.run {
                    dismiss()
                    onDismiss()
                }
            } catch {
                print("Error generating new code: \(error)")
            }
            await MainActor.run {
                isGeneratingCode = false
            }
        }
    }
} 