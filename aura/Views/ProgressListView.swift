import SwiftUI

struct ProgressListView: View {
    @StateObject var viewModel: ProgressViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if !viewModel.analyses.isEmpty {
                        ForEach(viewModel.analyses) { analysis in
                            NavigationLink(destination: AnalysisResultScreen(analysis: analysis, onNewAnalysis: {})) {
                                ProgressTimelineCard(analysis: analysis)
                                    .padding(.horizontal)
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "No Analysis Yet",
                            systemImage: "chart.line.uptrend.xyaxis",
                            description: Text("Complete your first hair analysis to start tracking your progress")
                        )
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                // This is the native SwiftUI pull-to-refresh
                await viewModel.loadAnalyses()
            }
            .background(AuraTheme.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AuraLogo(size: 32)
                }
            }
        }
    }
}

struct ProgressTimelineCard: View {
    let analysis: HairAnalysis
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(analysis.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Hair Analysis")
                        .font(.headline)
                }
                
                Spacer()
                
                Text("\(analysis.overallScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AuraTheme.gradient)
            }
            
            Divider()
            
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AuraTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
} 