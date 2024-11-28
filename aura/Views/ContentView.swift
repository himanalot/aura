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
