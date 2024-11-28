import SwiftUI

struct AuraLogo: View {
    var size: CGFloat = 24
    
    var body: some View {
        Text("aura")
            .font(.custom("Helvetica Neue", size: size))
            .fontWeight(.medium)
            .foregroundStyle(AuraTheme.gradient)
            .frame(maxWidth: .infinity, alignment: .center)
    }
} 