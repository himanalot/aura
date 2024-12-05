import SwiftUI

struct AnalysisResultScreen: View {
    let analysis: HairAnalysis
    let onNewAnalysis: () -> Void
    
    var body: some View {
        ZStack {
            AuraTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header with score
                    ScoreCircleView(score: analysis.overallScore)
                        .frame(height: 240)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                    
                    // Categories
                    VStack(spacing: 20) {
                        Text("Hair Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AuraTheme.gradient)
                        
                        CategoryScoresView(scores: analysis.ratings.scores)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    )
                    
                    // Recommendations
                    VStack(spacing: 20) {
                        RecommendationsView(recommendations: analysis.recommendations)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    )
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AuraLogo(size: 32)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onNewAnalysis) {
                    Label("New Analysis", systemImage: "plus.circle.fill")
                        .foregroundStyle(AuraTheme.gradient)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AnalysisResultScreen(
            analysis: HairAnalysis(
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
                overallScore: 85,
                recommendations: Recommendations(
                    products: [
                        ProductRecommendation(
                            category: "Shampoo",
                            name: "Kerastase Nutritive Shampoo",
                            reason: "Provides deep hydration for your hair type"
                        ),
                        ProductRecommendation(
                            category: "Treatment",
                            name: "Olaplex No. 3",
                            reason: "Helps repair and strengthen hair bonds"
                        )
                    ],
                    techniques: [
                        "Use a microfiber towel to dry your hair",
                        "Deep condition weekly"
                    ],
                    lifestyle: [
                        "Increase protein intake",
                        "Stay hydrated"
                    ]
                ),
                date: Date()
            )
        ) {}
    }
} 