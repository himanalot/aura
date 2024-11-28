import Foundation
import FirebaseAuth

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var analyses: [HairAnalysis] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func loadAnalyses() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            analyses = try await FirebaseService.shared.fetchHairAnalyses(userId: userId)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
} 