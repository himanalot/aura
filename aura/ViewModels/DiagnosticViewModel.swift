import Foundation

class DiagnosticViewModel: ObservableObject {
    @Published var questions = [
        DiagnosticQuestion(
            question: "How would you describe your hair type?",
            options: ["Straight", "Wavy", "Curly", "Coily"]
        ),
        DiagnosticQuestion(
            question: "What's your main hair concern?",
            options: ["Dryness", "Breakage", "Frizz", "Scalp Issues", "Hair Loss"]
        ),
        DiagnosticQuestion(
            question: "How often do you wash your hair?",
            options: ["Daily", "Every other day", "2-3 times a week", "Once a week"]
        ),
        DiagnosticQuestion(
            question: "How often do you use heat styling tools?",
            options: ["Never", "1-2 times a week", "3-4 times a week", "Daily"]
        ),
        DiagnosticQuestion(
            question: "Have you chemically treated your hair in the past 6 months?",
            options: ["No treatments", "Color only", "Relaxer/Perm", "Multiple treatments"]
        )
    ]
    
    @Published var currentQuestionIndex = 0
    @Published var isDiagnosticComplete = false
    
    var currentQuestion: DiagnosticQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    var canProceed: Bool {
        currentQuestion?.selectedOption != nil
    }
    
    func selectOption(_ option: String) {
        guard currentQuestionIndex < questions.count else { return }
        questions[currentQuestionIndex].selectedOption = option
    }
    
    func nextQuestion() {
        if isLastQuestion {
            completeDiagnostic()
        } else {
            currentQuestionIndex += 1
        }
    }
    
    func getAnswers() -> [String: String] {
        var answers: [String: String] = [:]
        for question in questions {
            if let answer = question.selectedOption {
                answers[question.question] = answer
            }
        }
        return answers
    }
    
    private func completeDiagnostic() {
        isDiagnosticComplete = true
    }
} 