import Foundation
import UIKit
import FirebaseAuth

class HairAnalysisViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var hairAnalysis: HairAnalysis?
    @Published var error: Error?
    
    private let apiKey: String
    private let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    
    init() {
        print("Checking for API key...")
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
            print("Found API key in Info.plist: \(apiKey.prefix(8))...")
            if apiKey.hasPrefix("${") {
                print("Error: API key contains raw variable - not properly substituted")
                fatalError("OpenAI API key not properly configured. Check Config.xcconfig and build settings")
            }
            self.apiKey = apiKey
        } else {
            print("No API key found in Info.plist")
            fatalError("OpenAI API key not found. Please set it in Config.xcconfig")
        }
    }
    
    func analyzeHair(image: UIImage) async throws {
        isAnalyzing = true
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": """
                            Analyze this hair image and provide a structured response with:
                            1. Hair thickness (fine/medium/thick)
                            2. Overall hair health score (poor/fair/good/excellent)
                            3. Three specific, actionable recommendations for improvement
                            Format the response in JSON.
                            """
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500,
            "temperature": 0.2
        ]
        
        var request = URLRequest(url: URL(string: openAIEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let jsonString = openAIResponse.choices.first?.message.content,
                  let jsonData = jsonString.data(using: .utf8) else {
                throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
            }
            
            let hairAnalysisResponse = try JSONDecoder().decode(HairAnalysisResponse.self, from: jsonData)
            
            await MainActor.run {
                self.hairAnalysis = HairAnalysis(
                    thickness: hairAnalysisResponse.thickness,
                    health: hairAnalysisResponse.health,
                    recommendations: hairAnalysisResponse.recommendations,
                    date: Date()
                )
                self.isAnalyzing = false
            }
            
            // Save to Firebase if user is logged in
            if let userId = Auth.auth().currentUser?.uid {
                try await FirebaseService.shared.saveHairAnalysis(self.hairAnalysis!, userId: userId)
            }
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isAnalyzing = false
            }
        }
    }
}

// Response structures for JSON parsing
private struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

private struct HairAnalysisResponse: Codable {
    let thickness: String
    let health: String
    let recommendations: [String]
}

struct HairAnalysis: Identifiable, Codable {
    let id = UUID()
    let thickness: String
    let health: String
    let recommendations: [String]
    let date: Date
} 
