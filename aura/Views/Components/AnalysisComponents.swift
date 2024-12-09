import SwiftUI

struct ScoreCircleView: View {
    let score: Int
    @State private var animateScore = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 16)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: animateScore ? CGFloat(score) / 100 : 0)
                    .stroke(
                        scoreGradient,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: animateScore)
                
                // Score display
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreGradient)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: score)
                    
                    Text("Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 200, height: 200) // Increased size
            .padding(.top, 24) // Added top padding
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateScore = true
            }
        }
    }
    
    private var scoreGradient: LinearGradient {
        switch score {
        case 0..<40:
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        case 40..<70:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        }
    }
}

struct StarsView: View {
    let score: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Image(systemName: starImageName(for: score, at: index))
                    .foregroundStyle(AuraTheme.gradient)
            }
        }
    }
    
    private func starImageName(for score: Double, at index: Int) -> String {
        if Double(index) + 0.5 == score {
            return "star.leadinghalf.filled"
        } else if Double(index) < score {
            return "star.fill"
        } else {
            return "star"
        }
    }
}

struct DistributionCurveView: View {
    let score: Int
    let mean: Double = 50
    let standardDeviation: Double = 15
    @State private var animateCurve = false
    @State private var animateMarker = false
    
    private let curvePoints = 200
    private let curveHeight: CGFloat = 320
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Score Distribution")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AuraTheme.gradient)
                .padding(.top, 8)
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let pointWidth = width / CGFloat(curvePoints)
                
                ZStack(alignment: .bottom) {
                    // Bell curve fill
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: curveHeight))
                        
                        for i in 0...curvePoints {
                            let x = CGFloat(i) * pointWidth
                            let score = Double(i) * (100.0 / Double(curvePoints))
                            let y = curveHeight * (1 - normalDistribution(score) * 8)
                            
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: curveHeight))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        path.addLine(to: CGPoint(x: width, y: curveHeight))
                    }
                    .fill(
                        LinearGradient(
                            colors: [
                                AuraTheme.primary.opacity(0.2),
                                AuraTheme.primary.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(animateCurve ? 1 : 0)
                    
                    // Curve line
                    Path { path in
                        for i in 0...curvePoints {
                            let x = CGFloat(i) * pointWidth
                            let score = Double(i) * (100.0 / Double(curvePoints))
                            let y = curveHeight * (1 - normalDistribution(score) * 8)
                            
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .trim(from: 0, to: animateCurve ? 1 : 0)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AuraTheme.primary,
                                AuraTheme.primary.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    
                    // User's score marker
                    let userX = CGFloat(score) * width / 100
                    let userY = curveHeight * (1 - normalDistribution(Double(score)) * 8)
                    
                    // Score label
                    Text("\(score)")
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(AuraTheme.gradient)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 4)
                        )
                        .position(x: userX, y: userY - 30) // Position above the dot
                        .opacity(animateMarker ? 1 : 0)
                    
                    // Score marker dot
                    Circle()
                        .fill(AuraTheme.gradient)
                        .frame(width: 8, height: 8)
                        .shadow(color: AuraTheme.primary.opacity(0.3), radius: 4)
                        .position(x: userX, y: userY) // Position directly on the curve
                        .opacity(animateMarker ? 1 : 0)
                }
            }
            .frame(height: curveHeight)
            
            // Distribution labels
            HStack {
                Text("Below Average")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Average")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Above Average")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 16, y: 4)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animateCurve = true
            }
            
            withAnimation(
                .spring(
                    response: 0.8,
                    dampingFraction: 0.6
                )
                .delay(0.8)
            ) {
                animateMarker = true
            }
        }
    }
    
    private func normalDistribution(_ x: Double) -> Double {
        let exponent = -pow(x - mean, 2) / (2 * pow(standardDeviation, 2))
        return exp(exponent) / (standardDeviation * sqrt(2 * .pi))
    }
}

struct RecommendationsView: View {
    let recommendations: Recommendations
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Products
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommended Products")
                    .font(.headline)
                    .foregroundStyle(AuraTheme.gradient)
                
                ForEach(recommendations.products, id: \.name) { product in
                    ProductRow(product: product)
                }
            }
            
            // Techniques
            VStack(alignment: .leading, spacing: 12) {
                Text("Care Techniques")
                    .font(.headline)
                    .foregroundStyle(AuraTheme.gradient)
                
                ForEach(recommendations.techniques, id: \.self) { technique in
                    RecommendationRow(text: technique)
                }
            }
            
            // Lifestyle
            VStack(alignment: .leading, spacing: 12) {
                Text("Lifestyle Tips")
                    .font(.headline)
                    .foregroundStyle(AuraTheme.gradient)
                
                ForEach(recommendations.lifestyle, id: \.self) { tip in
                    RecommendationRow(text: tip)
                }
            }
        }
    }
}

struct ProductRow: View {
    let product: ProductRecommendation
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AuraTheme.gradient)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(product.reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RecommendationRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AuraTheme.gradient)
            
            Text(text)
                .font(.subheadline)
        }
    }
}



// Distribution curve view
struct ScoreDistributionView: View {
    let scores: [Double]
    @State private var animateGraph = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Distribution")
                .font(.headline)
            
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Background grid
                    Path { path in
                        for i in 0...4 {
                            let x = CGFloat(i) * geometry.size.width / 4
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    
                    // Distribution curve
                    Path { path in
                        let points = calculateDistributionPoints(scores: scores, size: geometry.size)
                        path.move(to: points[0])
                        
                        for i in 1..<points.count {
                            let control = CGPoint(
                                x: (points[i-1].x + points[i].x) / 2,
                                y: min(points[i-1].y, points[i].y) - 20
                            )
                            path.addQuadCurve(to: points[i], control: control)
                        }
                    }
                    .trim(from: 0, to: animateGraph ? 1 : 0)
                    .stroke(AuraTheme.gradient, lineWidth: 2)
                    .animation(.easeInOut(duration: 1.2), value: animateGraph)
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .onAppear { animateGraph = true }
    }
    
    private func calculateDistributionPoints(scores: [Double], size: CGSize) -> [CGPoint] {
        // Implementation of distribution calculation
        // This is a placeholder - you'll need to implement the actual distribution logic
        return []
    }
} 
