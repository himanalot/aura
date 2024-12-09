import SwiftUI

struct UploadPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(AuraTheme.gradient)
            
            VStack(spacing: 8) {
                Text("Take or Upload a Photo")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("We'll analyze your hair and provide personalized recommendations")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .padding(.vertical, 32)
    }
} 