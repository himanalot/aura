import SwiftUI

struct CategoryScoresView: View {
    let scores: CategoryScores
    @State private var selectedCategory: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detailed Analysis")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                CategoryScoreView(
                    label: "Moisture",
                    score: scores.moisture,
                    description: "Water retention and hydration levels"
                )
                .onTapGesture { selectedCategory = "Moisture" }
                
                CategoryScoreView(
                    label: "Damage",
                    score: scores.damage,
                    description: "Overall hair structure health"
                )
                .onTapGesture { selectedCategory = "Damage" }
                
                CategoryScoreView(
                    label: "Texture",
                    score: scores.texture,
                    description: "Hair pattern and smoothness"
                )
                .onTapGesture { selectedCategory = "Texture" }
                
                CategoryScoreView(
                    label: "Frizz",
                    score: scores.frizz,
                    description: "Flyaway and frizz control"
                )
                .onTapGesture { selectedCategory = "Frizz" }
                
                CategoryScoreView(
                    label: "Shine",
                    score: scores.shine,
                    description: "Light reflection and glossiness"
                )
                .onTapGesture { selectedCategory = "Shine" }
                
                CategoryScoreView(
                    label: "Density",
                    score: scores.density,
                    description: "Hair thickness and volume"
                )
                .onTapGesture { selectedCategory = "Density" }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
} 