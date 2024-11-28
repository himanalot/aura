import Foundation
import FirebaseAuth

class ProgressViewModel: ObservableObject {
    @Published var analyses: [HairAnalysis] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func loadAnalyses() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        Task {
            do {
                let analyses = try await FirebaseService.shared.getHairAnalyses(for: userId)
                await MainActor.run {
                    self.analyses = analyses.sorted(by: { $0.date > $1.date })
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
} 