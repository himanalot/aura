import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title)
                    .bold()
                
                Group {
                    Text("Data Collection")
                        .font(.headline)
                    Text("We collect hair analysis data and images to provide personalized recommendations. All data is stored securely and encrypted.")
                    
                    Text("Data Usage")
                        .font(.headline)
                    Text("Your data is used to:\n• Analyze hair health\n• Track progress over time\n• Generate personalized recommendations")
                    
                    Text("Data Protection")
                        .font(.headline)
                    Text("We implement industry-standard security measures to protect your personal information. Images and analysis results are stored securely in encrypted format.")
                    
                    Text("Data Sharing")
                        .font(.headline)
                    Text("We do not share your personal data with third parties. Your hair analysis data is private and accessible only to you.")
                }
                
                Group {
                    Text("User Rights")
                        .font(.headline)
                    Text("You have the right to:\n• Access your data\n• Request data deletion\n• Opt out of data collection")
                    
                    Text("Contact Us")
                        .font(.headline)
                    Text("For privacy-related inquiries, please contact us at privacy@aura.com")
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
    }
} 