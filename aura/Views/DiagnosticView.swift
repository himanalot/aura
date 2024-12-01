import SwiftUI
import FirebaseAuth

struct DiagnosticView: View {
    @StateObject private var viewModel = DiagnosticViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                ProgressView(value: Double(viewModel.currentQuestionIndex + 1), total: Double(viewModel.questions.count))
                    .tint(Color.accentColor)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 32) {
                        Text("Let's understand your hair better")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                        
                        if let question = viewModel.currentQuestion {
                            VStack(alignment: .leading, spacing: 20) {
                                Text(question.question)
                                    .font(.headline)
                                    .padding(.bottom)
                                
                                VStack(spacing: 12) {
                                    ForEach(question.options, id: \.self) { option in
                                        Button(action: { viewModel.selectOption(option) }) {
                                            HStack {
                                                Text(option)
                                                    .foregroundColor(option == question.selectedOption ? .white : .primary)
                                                Spacer()
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(option == question.selectedOption ? Color.accentColor : Color(.systemBackground))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                if !viewModel.isDiagnosticComplete {
                    Button(action: viewModel.nextQuestion) {
                        Text(viewModel.isLastQuestion ? "Complete" : "Next")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.canProceed ? Color.accentColor : Color.gray)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.canProceed)
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: viewModel.isDiagnosticComplete) { completed in
            if completed {
                Task {
                    do {
                        if let userId = Auth.auth().currentUser?.uid {
                            let results = DiagnosticResults(
                                answers: viewModel.getAnswers(),
                                date: Date(),
                                userId: userId
                            )
                            try await FirebaseService.shared.saveDiagnosticResults(results)
                            
                            DispatchQueue.main.async {
                                authViewModel.isSignedIn = true
                                dismiss()
                            }
                        }
                    } catch {
                        print("Error saving diagnostic: \(error)")
                        DispatchQueue.main.async {
                            authViewModel.isSignedIn = true
                            dismiss()
                        }
                    }
                }
            }
        }
    }
} 