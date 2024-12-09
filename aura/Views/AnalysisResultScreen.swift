import SwiftUI

// Add this if DistributionCurveView is in a separate module
// import AuraComponents 

struct AnalysisResultScreen: View {
    let analysis: HairAnalysis
    let onNewAnalysis: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    AuraTheme.primary.opacity(0.8),
                    AuraTheme.accent.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header with score
                    ScoreCircleView(score: analysis.overallScore)
                        .frame(height: 240)
                        .padding(.top, 24)
                    
                    // Detailed Analysis
                    VStack(spacing: 20) {
                        Text("Detailed Analysis")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        CategoryScoresView(scores: analysis.ratings.scores)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.15), radius: 12)
                    
                    // Distribution Curve
                    VStack(spacing: 20) {
                        Text("Score Distribution")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        ScoreDistributionView(score: analysis.overallScore)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.15), radius: 12)
                    
                    // Recommendations
                    VStack(spacing: 20) {
                        Text("Recommendations")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        RecommendationsView(recommendations: analysis.recommendations)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.15), radius: 12)
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
                        .foregroundColor(.white)
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
