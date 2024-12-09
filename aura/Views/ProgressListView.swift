import SwiftUI

struct ProgressListView: View {
    @StateObject var viewModel: ProgressViewModel

    
    var body: some View {
        NavigationView {
            ZStack {
                // Added gradient background
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
                    VStack(spacing: 24) {
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
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 24)
                }
            }
            .refreshable {
                await viewModel.loadAnalyses()
            }
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
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(analysis.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Hair Analysis")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(analysis.overallScore)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AuraTheme.gradient)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                CategoryScoreItem(label: "Moisture", score: analysis.ratings.scores.moisture)
                CategoryScoreItem(label: "Damage", score: analysis.ratings.scores.damage)
                CategoryScoreItem(label: "Texture", score: analysis.ratings.scores.texture)
                CategoryScoreItem(label: "Frizz", score: analysis.ratings.scores.frizz)
                CategoryScoreItem(label: "Shine", score: analysis.ratings.scores.shine)
                CategoryScoreItem(label: "Density", score: analysis.ratings.scores.density)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
} 
