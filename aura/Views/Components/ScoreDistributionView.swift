import SwiftUI

struct ScoreDistributionView: View {
    let score: Int
    let mean: Double = 50
    let standardDeviation: Double = 8
    @State private var animateCurve = false
    @State private var animateMarker = false
    
    private let curvePoints = 200
    private let curveHeight: CGFloat = 120
    
    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                ZStack {
                    // Background curve
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height * 0.8
                        
                        for x in 0...curvePoints {
                            let point = CGFloat(x) / CGFloat(curvePoints)
                            let xPos = point * width
                            let normalValue = normalDistribution(x: Double(point) * 100)
                            let yPos = height - (normalValue * height * 8)
                            
                            if x == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            } else {
                                path.addLine(to: CGPoint(x: xPos, y: yPos))
                            }
                        }
                    }
                    .trim(from: 0, to: animateCurve ? 1 : 0)
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    
                    // Score indicator
                    Circle()
                        .fill(AuraTheme.gradient)
                        .frame(width: 16, height: 16)
                        .position(
                            x: CGFloat(score) / 100 * geometry.size.width,
                            y: geometry.size.height * 0.8 - (normalDistribution(x: Double(score)) * geometry.size.height * 0.8 * 8)
                        )
                        .shadow(color: AuraTheme.primary.opacity(0.3), radius: 4)
                        .opacity(animateMarker ? 1 : 0)
                }
            }
            .frame(height: curveHeight)
            
            // Score labels
            HStack {
                Text("0")
                Spacer()
                Text("50")
                Spacer()
                Text("100")
            }
            .foregroundColor(.white.opacity(0.8))
            .font(.caption)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateCurve = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
                animateMarker = true
            }
        }
    }
    
    private func normalDistribution(x: Double) -> Double {
        let variance = standardDeviation * standardDeviation
        let exponent = -pow(x - mean, 2) / (2 * variance)
        return exp(exponent) / (standardDeviation * sqrt(2 * .pi))
    }
}

#Preview {
    ZStack {
        Color.black
        ScoreDistributionView(score: 75)
            .padding()
    }
} 