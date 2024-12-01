import SwiftUI
import FirebaseAuth

struct ReferralShareView: View {
    @Environment(\.dismiss) private var dismiss
    let referralCode: ReferralCode
    let onDismiss: () -> Void
    @State private var codeCopied = false
    
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
                        Text("Code fully used! You now have a free analysis!")
                            .foregroundColor(.green)
                            .font(.headline)
                    }
                }
                
                Button(action: {
                    UIPasteboard.general.string = referralCode.code
                    codeCopied = true
                    
                    // Reset the copied state after 2 seconds
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
} 