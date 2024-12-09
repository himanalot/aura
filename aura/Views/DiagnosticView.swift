import SwiftUI
import FirebaseAuth

struct DiagnosticView: View {
    @StateObject private var viewModel = DiagnosticViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            DiagnosticContent(
                viewModel: viewModel,
                dismiss: dismiss,
                authViewModel: authViewModel
            )
        }
    }
}

// Break up the complex view into a separate component
struct DiagnosticContent: View {
    @ObservedObject var viewModel: DiagnosticViewModel
    let dismiss: DismissAction
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 24) {
                progressView
                
                ScrollView {
                    VStack(spacing: 32) {
                        headerText
                        
                        if let question = viewModel.currentQuestion {
                            questionView(question)
                        }
                    }
                    .padding()
                }
                
                if !viewModel.isDiagnosticComplete {
                    nextButton
                }
            }
        }
        .task {
            await checkExistingDiagnostic()
        }
        .onChange(of: viewModel.isDiagnosticComplete) { completed in
            if completed {
                Task {
                    await handleDiagnosticCompletion()
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AuraTheme.primary.opacity(0.8),
                AuraTheme.accent.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var progressView: some View {
        ProgressView(
            value: Double(viewModel.currentQuestionIndex + 1),
            total: Double(viewModel.questions.count)
        )
        .tint(.white)
        .padding(.horizontal)
    }
    
    private var headerText: some View {
        Text("Let's understand your hair better")
            .font(.system(.title2, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.top)
    }
    
    private func questionView(_ question: DiagnosticQuestion) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question.question)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom)
            
            optionsStack(for: question)
        }
    }
    
    private func optionsStack(for question: DiagnosticQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.options, id: \.self) { option in
                optionButton(option: option, selectedOption: question.selectedOption)
            }
        }
    }
    
    private func optionButton(option: String, selectedOption: String?) -> some View {
        Button(action: { viewModel.selectOption(option) }) {
            HStack {
                Text(option)
                    .foregroundColor(option == selectedOption ? .white : .primary)
                Spacer()
            }
            .frame(height: 56)
            .padding(.horizontal)
            .background(
                Group {
                    if option == selectedOption {
                        AuraTheme.gradient
                    } else {
                        Color(.systemBackground)
                    }
                }
            )
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(28)
            .shadow(color: AuraTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
    }
    
    private var nextButton: some View {
        Button(action: viewModel.nextQuestion) {
            Text(viewModel.isLastQuestion ? "Complete" : "Next")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if viewModel.canProceed {
                            AuraTheme.gradient
                        } else {
                            Color(.systemBackground)
                        }
                    }
                )
                .background(.ultraThinMaterial)
                .foregroundColor(.white)
                .cornerRadius(28)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: AuraTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(!viewModel.canProceed)
        .padding(.horizontal)
    }
    
    private func checkExistingDiagnostic() async {
        if let userId = Auth.auth().currentUser?.uid {
            do {
                let results = try await FirebaseService.shared.fetchLatestDiagnosticResults(userId: userId)
                if results != nil {
                    dismiss()
                }
            } catch {
                print("Error fetching diagnostic results: \(error)")
            }
        }
    }
    
    private func handleDiagnosticCompletion() async {
        do {
            if let userId = Auth.auth().currentUser?.uid {
                let results = DiagnosticResults(
                    answers: viewModel.getAnswers(),
                    date: Date(),
                    userId: userId
                )
                try await FirebaseService.shared.saveDiagnosticResults(results)
                
                await MainActor.run {
                    authViewModel.isSignedIn = true
                    dismiss()
                }
            }
        } catch {
            print("Error saving diagnostic: \(error)")
            await MainActor.run {
                authViewModel.isSignedIn = true
                dismiss()
            }
        }
    }
}
