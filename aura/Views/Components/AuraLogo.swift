import SwiftUI

struct AuraLogo: View {
    var size: CGFloat = 24
    var showText: Bool = true
    
    var body: some View {
        HStack(spacing: 8) {
            Image("aura-icon")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            
            if showText {
                Text("aura")
                    .font(.custom("Helvetica Neue", size: size * 0.8))
                    .fontWeight(.medium)
                    .foregroundStyle(AuraTheme.gradient)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
} 