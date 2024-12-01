import Foundation

struct DiagnosticQuestion: Identifiable, Codable {
    let id = UUID()
    let question: String
    let options: [String]
    var selectedOption: String?
}

struct DiagnosticResults: Codable {
    let answers: [String: String]
    let date: Date
    let userId: String
} 