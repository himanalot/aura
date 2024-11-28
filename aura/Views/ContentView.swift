import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                TabView(selection: $selectedTab) {
                    HairAnalysisView()
                        .tabItem {
                            Label("Analyze", systemImage: "camera.fill")
                        }
                        .tag(0)
                    
                    ProgressListView(viewModel: progressViewModel)
                        .tabItem {
                            Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .tag(1)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(2)
                }
                .onAppear {
                    progressViewModel.loadAnalyses()
                }
                .preferredColorScheme(.dark)
            } else {
                LoginView()
                    .preferredColorScheme(.dark)
            }
        }
        .environmentObject(authViewModel)
        .tint(AuraTheme.primaryPurple)
    }
}

struct ProgressListView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.analyses.isEmpty {
                EmptyProgressView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.analyses) { analysis in
                            ProgressCardView(analysis: analysis)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Progress")
            }
        }
    }
}

struct EmptyProgressView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("No Analysis Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Take your first hair analysis to start tracking your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct ProgressCardView: View {
    let analysis: HairAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(analysis.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Score: \(analysis.overallScore)")
                    .font(.headline)
                    .foregroundColor(scoreColor)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Thickness")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(analysis.ratings.thickness)
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading) {
                    Text("Health")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(analysis.ratings.health)
                        .font(.subheadline)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    var scoreColor: Color {
        switch analysis.overallScore {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .yellow
        default: return .red
        }
    }
}

#Preview {
    ContentView()
} 