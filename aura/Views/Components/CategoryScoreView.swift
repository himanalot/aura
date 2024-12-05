import SwiftUI

struct CategoryScoreView: View {
    let label: String
    let score: Double
    let description: String
    @State private var animateScore = false
    @State private var isPressed = false
    
    private var normalizedScore: Int {
        let rawScore = score
        switch label.lowercased() {
        case "damage", "frizz":
            return Int(min(100, max(0, 100 - rawScore)))
        default:
            return Int(min(100, max(0, rawScore)))
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Glowing background effect
                Circle()
                    .fill(scoreGradient.opacity(0.1))
                    .frame(width: 110, height: 110)
                    .blur(radius: isPressed ? 10 : 5)
                
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 10)
                    .frame(width: 100, height: 100)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: animateScore ? CGFloat(normalizedScore) / 100 : 0)
                    .stroke(
                        scoreGradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                // Score text
                Text("\(normalizedScore)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreGradient)
                    .contentTransition(.numericText())
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AuraTheme.gradient)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: 160)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animateScore = true
            }
        }
        .pressEvents {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
    
    private var scoreGradient: LinearGradient {
        switch normalizedScore {
        case 0..<40:
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        case 40..<70:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        }
    }
}

// Helper for pressure sensitivity
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
} 