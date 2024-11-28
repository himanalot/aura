import SwiftUI

struct AuraTheme {
    // Primary brand color - a sophisticated deep teal
    static let primary = Color(hex: "#006D77")
    
    // Secondary accent - a soft rose gold
    static let accent = Color(hex: "#E29C93")
    
    // Modern, elegant gradient
    static let gradient = LinearGradient(
        colors: [
            Color(hex: "#006D77"),  // Deep teal
            Color(hex: "#83C5BE")   // Soft teal
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Subtle background gradient
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(.systemBackground),
            Color(.systemBackground).opacity(0.98)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Card backgrounds with subtle transparency
    static let cardBackground = Color(.systemBackground).opacity(0.95)
    
    // Text colors
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    
    // Semantic colors
    static let success = Color(hex: "#2D6A4F")  // Deep green
    static let warning = Color(hex: "#CB997E")  // Muted terra cotta
    static let error = Color(hex: "#BC4749")    // Muted red
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