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
