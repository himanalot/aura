import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.title)
                    .bold()
                
                Group {
                    Text("Acceptance of Terms")
                        .font(.headline)
                    Text("By using Aura Hair Health Analyzer, you agree to these terms of service.")
                    
                    Text("Service Description")
                        .font(.headline)
                    Text("Aura provides AI-powered hair health analysis and recommendations. Results are for informational purposes only and should not be considered medical advice.")
                    
                    Text("User Responsibilities")
                        .font(.headline)
                    Text("Users must:\n• Provide accurate information\n• Use the app responsibly\n• Not misuse or attempt to deceive the AI system")
                }
                
                Group {
                    Text("Limitations")
                        .font(.headline)
                    Text("The app's analysis and recommendations are not substitutes for professional medical advice. Consult healthcare professionals for medical concerns.")
                    
                    Text("Intellectual Property")
                        .font(.headline)
                    Text("All content, features, and functionality are owned by Aura and protected by international copyright laws.")
                    
                    Text("Changes to Terms")
                        .font(.headline)
                    Text("We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.")
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        TermsOfServiceView()
    }
} 