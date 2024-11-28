import Foundation
import UIKit
import FirebaseAuth

class HairAnalysisViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var hairAnalysis: HairAnalysis?
    @Published var error: Error?
    @Published var analysisProgress: String = ""
    
    private let apiKey: String
    private let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    
    init() {
        print("Loading API key from file system...")
        
        // Get the path to Config.xcconfig
        if let configPath = Bundle.main.path(forResource: "Config", ofType: "xcconfig") {
            do {
                let contents = try String(contentsOfFile: configPath, encoding: .utf8)
                // Parse the OPENAI_API_KEY from the file
                if let apiKeyLine = contents.components(separatedBy: .newlines)
                    .first(where: { $0.hasPrefix("OPENAI_API_KEY") }),
                   let apiKey = apiKeyLine.components(separatedBy: "=").last?.trimmingCharacters(in: .whitespaces) {
                    print("Found API key in Config.xcconfig: \(apiKey.prefix(8))...")
                    self.apiKey = apiKey
                    print("API key loaded successfully")
                } else {
                    print("Error: Could not find OPENAI_API_KEY in Config.xcconfig")
                    fatalError("OpenAI API key not found in Config.xcconfig")
                }
            } catch {
                print("Error reading Config.xcconfig: \(error)")
                fatalError("Could not read Config.xcconfig: \(error)")
            }
        } else {
            print("Error: Config.xcconfig not found in bundle")
            fatalError("Config.xcconfig not found in bundle")
        }
    }
    
    func analyzeHair(image: UIImage) async throws {
        print("Starting hair analysis...")
        await MainActor.run {
            isAnalyzing = true
            analysisProgress = "Processing image..."
        }
        
        // Resize image to reduce size
        let maxDimension: CGFloat = 512
        let scale = maxDimension / max(image.size.width, image.size.height)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            print("Failed to process image data")
            throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
        }
        
        let base64Image = imageData.base64EncodedString()
        print("Image converted to base64")
        print("Base64 length: \(base64Image.count)")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": """
                                Analyze this hair image and provide a JSON response \
                                with the keys 'thickness', 'health', and 'recommendations', \
                                where thickness is one of (fine/medium/thick), health is one of (poor/fair/good/excellent), \
                                and recommendations is a list of three suggestions.
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
            "max_tokens": 1000,
            "temperature": 0.0
        ]
        
        print("Preparing API request...")
        var request = URLRequest(url: URL(string: openAIEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Print request for debugging
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request body:")
            print(jsonString)
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("Sending request to OpenAI...")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Received response with status code: \(httpResponse.statusCode)")
            print("Response headers: \(httpResponse.allHeaderFields)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "No response body"
        print("Raw response: \(responseString)")
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let jsonString = openAIResponse.choices.first?.message.content else {
            throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        // Clean up JSON string by removing code block markers if present
        let cleanJsonString = jsonString.replacingOccurrences(of: "```json\n", with: "")
            .replacingOccurrences(of: "\n```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanJsonString.data(using: .utf8) else {
            throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        
        let hairAnalysisResponse = try JSONDecoder().decode(HairAnalysisResponse.self, from: jsonData)
        
        await MainActor.run {
            self.hairAnalysis = HairAnalysis(
                thickness: hairAnalysisResponse.thickness,
                health: hairAnalysisResponse.health,
                recommendations: hairAnalysisResponse.recommendations,
                date: Date()
            )
            self.analysisProgress = ""
            self.isAnalyzing = false
        }
        
        if let userId = Auth.auth().currentUser?.uid {
            print("Saving analysis to Firebase...")
            try await FirebaseService.shared.saveHairAnalysis(self.hairAnalysis!, userId: userId)
            print("Analysis saved successfully")
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
