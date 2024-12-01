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
        print("📸 Starting analysis...")
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
                    "role": "system",
                    "content": """
                        You are a professional hair analysis expert with deep knowledge of trichology, hair care products, and techniques. 
                        Provide detailed analysis with specific product recommendations and techniques.
                        Focus on evidence-based analysis and proven solutions.
                        """
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": """
                                Analyze this hair image in detail and provide a JSON response with detailed ratings and specific recommendations.
                                
                                Required JSON structure:
                                {
                                    "ratings": {
                                        "thickness": one of ("fine", "medium", "thick"),
                                        "health": one of ("poor", "fair", "good", "excellent"),
                                        "scores": {
                                            "moisture": (0-5 rating, can use .5 increments),
                                            "damage": (0-5 rating),
                                            "texture": (0-5 rating),
                                            "frizz": (0-5 rating),
                                            "shine": (0-5 rating),
                                            "density": (0-5 rating),
                                            "elasticity": (0-5 rating)
                                        }
                                    },
                                    "overallScore": (0-100),
                                    "recommendations": {
                                        "products": [
                                            {
                                                "category": "product category",
                                                "name": "specific product name",
                                                "reason": "why this product"
                                            }
                                        ],
                                        "techniques": [
                                            "specific styling or care techniques"
                                        ],
                                        "lifestyle": [
                                            "diet, habits, or environmental recommendations"
                                        ]
                                    }
                                }
                                
                                Analysis Guidelines:
                                1. Score each category based on visible indicators
                                2. Calculate overall score weighted across all categories
                                3. Recommend specific, commercially available products
                                4. Include both immediate solutions and long-term care strategies
                                5. Consider hair type and visible characteristics
                                6. Provide practical, actionable techniques
                                
                                Categories to analyze:
                                - Moisture level and hydration
                                - Damage assessment (split ends, chemical damage)
                                - Scalp condition and health
                                - Breakage and structural integrity
                                - Shine and surface condition
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
            "max_tokens": 1500,
            "temperature": 0.3
        ]
        
        print("🔄 Processing image...")
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
        
        print("📤 Sending to API...")
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
        
        // Extract JSON from the response more robustly
        let jsonRegex = try? NSRegularExpression(pattern: "```json\\s*\\n?(.*?)\\n?```", options: [.dotMatchesLineSeparators])
        guard let match = jsonRegex?.firstMatch(in: jsonString, range: NSRange(jsonString.startIndex..., in: jsonString)),
              let range = Range(match.range(at: 1), in: jsonString) else {
            // If no JSON block found, try to parse the entire string
            let cleanJsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let jsonData = cleanJsonString.data(using: .utf8) else {
                throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
            }
            let hairAnalysisResponse = try JSONDecoder().decode(HairAnalysisResponse.self, from: jsonData)
            return await processAnalysisResponse(hairAnalysisResponse)
        }
        
        let extractedJson = String(jsonString[range])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = extractedJson.data(using: .utf8) else {
            throw NSError(domain: "HairAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        
        let hairAnalysisResponse = try JSONDecoder().decode(HairAnalysisResponse.self, from: jsonData)
        await processAnalysisResponse(hairAnalysisResponse)
    }
    
    // Helper function to process the response
    private func processAnalysisResponse(_ response: HairAnalysisResponse) async {
        await MainActor.run {
            self.hairAnalysis = HairAnalysis(
                ratings: response.ratings,
                overallScore: response.overallScore,
                recommendations: response.recommendations,
                date: Date()
            )
            self.analysisProgress = ""
            self.isAnalyzing = false
        }
        
        if let userId = Auth.auth().currentUser?.uid {
            print("💾 Saving results...")
            try? await FirebaseService.shared.saveHairAnalysis(self.hairAnalysis!, userId: userId)
            print("Analysis saved successfully")
        }
    }
    
    private func calculateOverallScore(scores: CategoryScores) -> Int {
        // Convert damage score to a positive metric (5 - damage score)
        // Higher damage score = worse condition, so we invert it
        let damagePositive = 5.0 - scores.damage
        
        // Weight the categories
        let weights: [String: Double] = [
            "moisture": 1.0,
            "damage": 1.2,    // Weighted higher due to importance
            "texture": 1.0,
            "frizz": 0.8,     // Slightly lower weight (more cosmetic)
            "shine": 0.8,     // Slightly lower weight (more cosmetic)
            "density": 0.9,
            "elasticity": 1.0
        ]
        
        // Calculate weighted average
        let weightedSum = (
            scores.moisture * weights["moisture"]! +
            damagePositive * weights["damage"]! +
            scores.texture * weights["texture"]! +
            scores.frizz * weights["frizz"]! +
            scores.shine * weights["shine"]! +
            scores.density * weights["density"]! +
            scores.elasticity * weights["elasticity"]!
        )
        
        let totalWeight = weights.values.reduce(0, +)
        
        // Convert to 0-100 scale
        return Int((weightedSum / totalWeight) * 20)
    }
    
    private func generateLifestyleTips(scores: CategoryScores) -> [String] {
        var tips: [String] = []
        
        // Moisture-based tips
        if scores.moisture < 3.5 {
            tips.append(contentsOf: [
                "Increase water intake to at least 8 glasses daily",
                "Consider using a humidifier in your bedroom",
                "Include omega-3 rich foods like salmon and avocados in your diet"
            ])
        }
        
        // Damage-based tips
        if scores.damage > 3.0 {
            tips.append(contentsOf: [
                "Limit heat styling to once or twice a week",
                "Use a silk or satin pillowcase to reduce friction",
                "Take biotin supplements after consulting with your healthcare provider"
            ])
        }
        
        // Scalp health tips
        if scores.texture < 4.0 {
            tips.append(contentsOf: [
                "Maintain a balanced diet rich in zinc and vitamin B",
                "Practice scalp massage during washing",
                "Avoid tight hairstyles that can stress the scalp"
            ])
        }
        
        // Breakage-specific tips
        if scores.frizz > 3.0 {
            tips.append(contentsOf: [
                "Include more protein-rich foods in your diet",
                "Trim hair every 8-10 weeks",
                "Avoid chemical treatments until hair health improves"
            ])
        }
        
        // Porosity-based tips
        if scores.density < 3.0 || scores.density > 4.0 {
            tips.append(contentsOf: [
                "Balance your hair's pH with apple cider vinegar rinses",
                "Use lukewarm water instead of hot water when washing",
                "Consider your local water hardness and use appropriate filters"
            ])
        }
        
        // Select a random subset of relevant tips (3-4 tips)
        tips.shuffle()
        return Array(tips.prefix(min(4, tips.count)))
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
    let ratings: HairRatings
    let overallScore: Int  // 0-100
    let recommendations: Recommendations
}

struct HairRatings: Codable, Hashable {
    let thickness: String  // fine/medium/thick
    let health: String    // poor/fair/good/excellent
    let scores: CategoryScores
}

struct CategoryScores: Codable, Hashable {
    let moisture: Double     // 0-5, visible dryness/hydration
    let damage: Double      // 0-5, split ends and breakage
    let texture: Double     // 0-5, smoothness vs roughness
    let frizz: Double      // 0-5, frizz level
    let shine: Double      // 0-5, light reflection
    let density: Double    // 0-5, visible thickness/fullness
    let elasticity: Double // 0-5, visible curl pattern retention
}

struct Recommendations: Codable, Hashable {
    let products: [ProductRecommendation]
    let techniques: [String]
    let lifestyle: [String]
}

struct ProductRecommendation: Codable, Hashable {
    let category: String  // e.g., "Shampoo", "Conditioner", "Treatment"
    let name: String
    let reason: String
}

struct HairAnalysis: Identifiable, Codable, Hashable {
    let id = UUID()
    let ratings: HairRatings
    let overallScore: Int
    let recommendations: Recommendations
    let date: Date
    
    // Add Hashable conformance to nested types
    static func == (lhs: HairAnalysis, rhs: HairAnalysis) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 
