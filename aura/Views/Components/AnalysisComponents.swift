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

struct CategoryScoreView: View {
    let label: String
    let score: Double
    let description: String
    @State private var animateScore = false
    
    // Normalize scores to 0-100 range, handling negative values for problematic categories
    private var normalizedScore: Int {
        let rawScore = score
        switch label.lowercased() {
        case "damage", "frizz":
            // For negative categories, invert the score (100 - score)
            // Ensure the result is between 0-100
            return Int(min(100, max(0, 100 - rawScore)))
        default:
            // For positive categories, ensure score is between 0-100
            return Int(min(100, max(0, rawScore)))
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
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
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animateScore)
                
                // Score text
                Text("\(normalizedScore)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreGradient)
                    .contentTransition(.numericText())
            }
            
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: 160)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                animateScore = true
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
