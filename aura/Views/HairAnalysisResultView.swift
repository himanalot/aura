import SwiftUI

struct HairAnalysisResultView: View {
    let analysis: HairAnalysis
    
    var body: some View {
        VStack(spacing: 24) {
            // Overall Score
            ScoreCircleView(score: analysis.overallScore)
                .frame(height: 120)
            
            // Distribution Curve
            DistributionCurveView(score: analysis.overallScore)
            
            // Category Scores
            CategoryScoresView(scores: analysis.ratings.scores)
            
            // Recommendations
            RecommendationsView(recommendations: analysis.recommendations)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 3)
        )
    }
}

#Preview {
    HairAnalysisResultView(analysis: HairAnalysis(
        ratings: HairRatings(
            thickness: "Medium",
            health: "Good",
            scores: CategoryScores(
                moisture: 4.5,
                damage: 3.0,
                texture: 4.0,
                frizz: 3.5,
                shine: 4.0,
                density: 3.5,
                elasticity: 4.0
            )
        ),
        overallScore: 70,
        recommendations: Recommendations(
            products: [
                ProductRecommendation(category: "Shampoo", name: "Kerastase Shampoo", reason: "For deep hydration"),
                ProductRecommendation(category: "Conditioner", name: "Briogeo Conditioner", reason: "For damaged hair")
            ],
            techniques: [
                "Use a silk pillowcase to reduce friction",
                "Deep condition your hair weekly"
            ],
            lifestyle: [
                "Include more protein-rich foods in your diet",
                "Use a silk pillowcase to reduce friction"
            ]
        ),
        date: Date()
    ))
    .padding()
} 