import SwiftUI

struct AuraTheme {
    static let gradient = LinearGradient(
        colors: [
            Color(hex: "#00C6FF").opacity(0.9),  // Cyan
            Color(hex: "#B066FF").opacity(0.9),  // Purple
            Color(hex: "#FF69B4").opacity(0.9)   // Pink
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let primaryBlue = Color(hex: "#00C6FF")
    static let primaryPurple = Color(hex: "#B066FF")
    static let primaryPink = Color(hex: "#FF69B4")
    
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(.systemBackground).opacity(0.95),
            Color(.systemBackground)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardBackground = Color(.systemBackground).opacity(0.8)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 