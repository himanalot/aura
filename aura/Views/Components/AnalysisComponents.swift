import SwiftUI

struct ScoreCircleView: View {
    let score: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    AuraTheme.gradient,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: score)
            
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(AuraTheme.gradient)
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 140, height: 140)
        .background(
            Circle()
                .fill(AuraTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.15), radius: 10)
        )
    }
}

struct CategoryScoresView: View {
    let scores: CategoryScores
    
    private let categories: [(String, String, String)] = [
        ("moisture", "drop.fill", "Moisture"),
        ("damage", "exclamationmark.triangle.fill", "Damage"),
        ("scalp", "crown.fill", "Scalp Health"),
        ("breakage", "scissors", "Breakage"),
        ("shine", "sparkles", "Shine"),
        ("porosity", "bubble.right.fill", "Porosity"),
        ("elasticity", "arrow.up.and.down", "Elasticity")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(categories, id: \.0) { category, icon, label in
                if let score = scoreFor(category) {
                    HStack {
                        Image(systemName: icon)
                            .foregroundStyle(AuraTheme.gradient)
                            .frame(width: 30)
                        
                        Text(label)
                            .frame(width: 100, alignment: .leading)
                        
                        Spacer()
                        
                        StarsView(score: score)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func scoreFor(_ category: String) -> Double? {
        switch category {
        case "moisture": return scores.moisture
        case "damage": return scores.damage
        case "scalp": return scores.scalp
        case "breakage": return scores.breakage
        case "shine": return scores.shine
        case "porosity": return scores.porosity
        case "elasticity": return scores.elasticity
        default: return nil
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