import SwiftUI

struct CategoryScoreItem: View {
    let label: String
    let score: Double
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.1f", score))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(AuraTheme.gradient)
        }
    }
}

struct ProgressCardView: View {
    let analysis: HairAnalysis?
    
    var body: some View {
        VStack {
            if let analysis = analysis {
                VStack(spacing: 16) {
                    // Header with date and score
                    HStack {
                        Text(analysis.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(analysis.overallScore)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AuraTheme.gradient)
                    }
                    
                    Divider()
                    
                    // Category Scores Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        CategoryScoreItem(label: "Moisture", score: analysis.ratings.scores.moisture)
                        CategoryScoreItem(label: "Damage", score: analysis.ratings.scores.damage)
                        CategoryScoreItem(label: "Texture", score: analysis.ratings.scores.texture)
                        CategoryScoreItem(label: "Frizz", score: analysis.ratings.scores.frizz)
                        CategoryScoreItem(label: "Shine", score: analysis.ratings.scores.shine)
                        CategoryScoreItem(label: "Density", score: analysis.ratings.scores.density)
                    }
                }
            } else {
                // Centered empty state message
                Text("No analyses yet")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxHeight: 200) // Fixed height to maintain consistency
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AuraTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
} 