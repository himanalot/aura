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
                    Task {
                        await progressViewModel.loadAnalyses()
                        if let userId = Auth.auth().currentUser?.uid {
                            if let _ = try? await FirebaseService.shared.fetchLatestDiagnosticResults(userId: userId) {
                                authViewModel.showDiagnostic = false
                            } else {
                                authViewModel.showDiagnostic = true
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $authViewModel.showDiagnostic) {
                    DiagnosticView()
                }
                .preferredColorScheme(.dark)
            } else {
                LoginView()
                    .preferredColorScheme(.dark)
            }
        }
        .environmentObject(authViewModel)
        .tint(AuraTheme.primary)
    }
}
