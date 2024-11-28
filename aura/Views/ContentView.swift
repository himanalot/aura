import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HairAnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "camera.fill")
                }
            
            ProgressTrackingView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ProgressTrackingView: View {
    @StateObject private var viewModel = ProgressViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading history...")
                } else if viewModel.analyses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No analyses yet")
                            .font(.headline)
                        Text("Take your first hair analysis to start tracking progress")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    List(viewModel.analyses) { analysis in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Hair Health: \(analysis.health)")
                                    .font(.headline)
                                Spacer()
                                Text(analysis.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Text("Thickness: \(analysis.thickness)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Progress")
        }
        .onAppear {
            viewModel.loadAnalyses()
        }
    }
}

#Preview {
    ContentView()
} 