import SwiftUI

struct CategoryScoresView: View {
    let scores: CategoryScores
    @State private var selectedCategory: String?
    @State private var appearAnimation = false
    
    let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Detailed Analysis")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(AuraTheme.gradient)
            
            LazyVGrid(columns: columns, spacing: 24) {
                CategoryScoreView(
                    label: "Moisture",
                    score: scores.moisture,
                    description: "Water retention and hydration levels"
                )
                .offset(y: appearAnimation ? 0 : 50)
                .opacity(appearAnimation ? 1 : 0)
                .onTapGesture { selectedCategory = "Moisture" }
                
                CategoryScoreView(
                    label: "Damage",
                    score: scores.damage,
                    description: "Overall hair structure health"
                )
                .offset(y: appearAnimation ? 0 : 50)
                .opacity(appearAnimation ? 1 : 0)
                .onTapGesture { selectedCategory = "Damage" }
                
                CategoryScoreView(
                    label: "Texture",
                    score: scores.texture,
                    description: "Hair pattern and smoothness"
                )
                .offset(y: appearAnimation ? 0 : 50)
                .opacity(appearAnimation ? 1 : 0)
                .onTapGesture { selectedCategory = "Texture" }
                
                CategoryScoreView(
                    label: "Frizz",
                    score: scores.frizz,
                    description: "Flyaway and frizz control"
                )
                .offset(y: appearAnimation ? 0 : 50)
                .opacity(appearAnimation ? 1 : 0)
                .onTapGesture { selectedCategory = "Frizz" }
                
                CategoryScoreView(
                    label: "Shine",
                    score: scores.shine,
                    description: "Light reflection and glossiness"
                )
                .offset(y: appearAnimation ? 0 : 50)
                .opacity(appearAnimation ? 1 : 0)
                .onTapGesture { selectedCategory = "Shine" }
                
                CategoryScoreView(
                    label: "Density",
                    score: scores.density,
                    description: "Hair thickness and volume"
                )
                .offset(y: appearAnimation ? 0 : 50)
                .opacity(appearAnimation ? 1 : 0)
                .onTapGesture { selectedCategory = "Density" }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 16, y: 4)
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
} 