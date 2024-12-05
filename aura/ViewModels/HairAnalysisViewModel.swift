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
        
        let diagnosticResults = try? await FirebaseService.shared.fetchLatestDiagnosticResults(userId: Auth.auth().currentUser?.uid ?? "")
        
        let diagnosticInfo = if let results = diagnosticResults {
            results.answers.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        } else {
            "No diagnostic data available"
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": """
                        You are a professional hair and skin analysis expert and trichologist. Analyze images with extreme precision.
                        
                        Analysis Requirements:
                        1. Provide DETAILED analysis for both hair and skin separately
                        2. Each recommendation must be unique and highly specific
                        3. Include scientific reasoning for each recommendation
                        4. Recommendations must be at least 2-3 sentences each
                        5. Never repeat products or techniques
                        6. Rotate through different brands systematically
                        
                        Product Categories Required (minimum one from each):
                        - Cleansing Products
                        - Treatment Products
                        - Styling/Maintenance Products
                        - Specialty Products
                        
                        Care Technique Requirements:
                        1. Minimum 5 unique techniques
                        2. Include specific timing and frequency
                        3. Explain the scientific benefit
                        4. Include both immediate and long-term care plans
                        
                        Lifestyle Recommendations:
                        1. Diet-specific recommendations with foods and nutrients
                        2. Environmental protection measures
                        3. Sleep and stress management tips
                        4. Exercise and circulation benefits
                        5. Hydration and supplement guidance
                        
                        Product Lines (RECOMMEND DIVERSE PRODUCTS FROM MULTIPLE BRANDS):
                        
                        Men's Products:
                        - Based Body Works: Shampoo, Conditioner, Leave-In Conditioner
                        - Jack Black: Pure Clean Shampoo, Double Header Conditioner, MP10 Oil
                        - Baxter of California: Daily Shampoo, Daily Conditioner, Cream Pomade
                        - American Crew: Daily Shampoo, Daily Conditioner, Fiber, Forming Cream
                        - Redken Brews: Daily Shampoo, Daily Conditioner, Work Hard Paste
                        - Aveda Men: Pure-Formance Shampoo, Conditioner, Grooming Clay
                        - Lab Series: Daily Shampoo, Conditioner, Root Power Treatment
                        - Kiehl's: Fuel Shampoo, Conditioner, Texturizing Clay
                        - Bumble and Bumble: Sunday Shampoo, Super Rich Conditioner, Sumotech
                        - Malin+Goetz: Peppermint Shampoo, Cilantro Conditioner, Styling Cream
                        - Prose: Custom Shampoo, Custom Conditioner, Custom Hair Oil
                        - Hanz de Fuko: Natural Shampoo, Natural Conditioner, Claymation
                        - Blind Barber: Daily Shampoo, Daily Conditioner, 60 Proof Wax
                        - V76: Hydrating Shampoo, Hydrating Conditioner, Molding Paste
                        - Patricks: SH1 Shampoo, CD1 Conditioner, M2 Matte Pomade
                        
                        Women's Products:
                        - Olaplex: No.4 Shampoo, No.5 Conditioner, No.3 Treatment, No.6 Cream, No.7 Oil
                        - Kerastase: Bain Shampoo, Fondant Conditioner, Masque, Elixir Oil
                        - Briogeo: Don't Despair Repair Shampoo, Conditioner, Mask, Scalp Revival
                        - Davines: MOMO Shampoo, Conditioner, OI Oil, MELU Serum
                        - Living Proof: Perfect Hair Day Shampoo, Conditioner, Mask, 5-in-1 Cream
                        - Moroccanoil: Moisture Repair Shampoo, Conditioner, Treatment Oil
                        - Verb: Ghost Shampoo, Conditioner, Ghost Oil, Reset Mask
                        - Amika: Normcore Shampoo, Conditioner, The Kure Mask, Glass Action Oil
                        - R+Co: Television Shampoo, Conditioner, High Dive Cream, Death Valley Spray
                        - IGK: Hot Girls Shampoo, Conditioner, Rich Kid Oil, Good Behavior Cream
                        - Ouai: Fine Hair Shampoo, Medium Hair Conditioner, Treatment Mask, Wave Spray
                        - Bumble and Bumble: Thickening Shampoo, Conditioner, Invisible Oil
                        - Virtue: Recovery Shampoo, Conditioner, Healing Oil, Un-Frizz Cream
                        - Pureology: Hydrate Shampoo, Conditioner, Color Fanatic Spray
                        - Aveda: Botanical Repair Shampoo, Conditioner, Strengthening Treatment
                        - Drunk Elephant: Cocomino Shampoo, Cocomino Conditioner, Wild Marula Oil
                        - Bread Beauty: Hair Wash, Hair Mask, Hair Oil
                        - Pattern Beauty: Shampoo, Conditioner, Leave-In Conditioner
                        - Mizani: Moisture Fusion Shampoo, Conditioner, 25 Miracle Cream
                        - DevaCurl: No-Poo Original, One Condition Original, SuperCream
                        
                        Recommendation Rules:
                        1. Always try to choose random brands FROM the person's gender's product lines and find the best products, but don't choose a product that isn't right.
                        2. Match products to specific visible hair needs
                        3. Consider hair type, texture, and condition
                        4. Include mix of cleansing, treatment, and styling products
                        5. Recommend complementary products that work well together
                        6. Base recommendations on visible damage, dryness, or styling needs
                        7. Consider user's diagnostic information when selecting products
                        8. Select products based solely on hair needs, not brand preferences
                        9. Include specialty products for specific concerns
                        10. Mix premium and accessible options when appropriate
                        11. Choose products that work well together regardless of brand
                        12. Focus on addressing the most prominent hair concerns first
                        13. MUST use different brands for each recommendation
                        14. Rotate through different brands for each analysis
                        
                        Care Technique Formatting:
                        1. Start with action verb
                        2. Include specific timing
                        3. Keep under 80 characters
                        4. Format as: "Action: Specific steps (timing)"
                        Example: "Deep condition: Apply mask to damp hair, leave for 15 minutes"
                        
                        Scoring Guidelines:
                        1. Use precise numerical scores (0-100)
                        2. Consider multiple factors per category
                        3. Weight environmental factors
                        4. Account for visible damage patterns
                        5. Factor in texture and pattern variations
                        6. Consider age-appropriate characteristics
                        7. Evaluate seasonal impacts
                        
                        Response Format:
                        {
                            "hairAnalysis": {
                                "ratings": {
                                    "thickness": "fine|medium|thick",
                                    "health": "poor|fair|good|excellent",
                                    "scores": {
                                        "moisture": <1-100>,
                                        "damage": <1-100>,
                                        "texture": <1-100>,
                                        "frizz": <1-100>,
                                        "shine": <1-100>,
                                        "density": <1-100>,
                                        "elasticity": <1-100>
                                    }
                                },
                                "overallScore": <1-100>,
                                "recommendations": {
                                    "products": [
                                        {
                                            "category": "<category>",
                                            "name": "<specific product name>",
                                            "reason": "<detailed reason for recommendation>"
                                        }
                                    ],
                                    "techniques": [
                                        "<specific, detailed care instruction with timing>"
                                    ],
                                    "lifestyle": [
                                        "<specific lifestyle recommendation>"
                                    ]
                                }
                            },
                            "skinAnalysis": {
                                // mirror hair analysis format for skin
                            }
                        }
                        
                        User's diagnostic information:
                        \(diagnosticInfo)
                        
                        Guidelines:
                        1. Must return valid JSON in exactly this format
                        2. Include specific product names from the approved list
                        3. For men, always include at least one Based Body Works product
                        4. Provide detailed reasons for each recommendation
                        5. Include specific timing in care techniques
                        6. Base all scores on visible characteristics
                        """
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": """
                                Analyze this hair image and provide recommendations in the following EXACT JSON format:
                                
                                {
                                    "ratings": {
                                        "thickness": "fine|medium|thick",
                                        "health": "poor|fair|good|excellent",
                                        "scores": {
                                            "moisture": <1-100>,
                                            "damage": <1-100>,
                                            "texture": <1-100>,
                                            "frizz": <1-100>,
                                            "shine": <1-100>,
                                            "density": <1-100>,
                                            "elasticity": <1-100>
                                        }
                                    },
                                    "overallScore": <1-100>,
                                    "recommendations": {
                                        "products": [
                                            {
                                                "category": "<category>",
                                                "name": "<specific product name>",
                                                "reason": "<detailed reason for recommendation>"
                                            }
                                        ],
                                        "techniques": [
                                            "<specific, detailed care instruction with timing>"
                                        ],
                                        "lifestyle": [
                                            "<specific lifestyle recommendation>"
                                        ]
                                    }
                                }
                                
                                User's diagnostic information:
                                \(diagnosticInfo)
                                
                                Guidelines:
                                1. Must return valid JSON in exactly this format
                                2. Include specific product names from the approved list
                                3. For men, always include at least one Based Body Works product
                                4. Provide detailed reasons for each recommendation
                                5. Include specific timing in care techniques
                                6. Base all scores on visible characteristics
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
            "temperature": 0.7
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
    private func processAnalysisResponse(_ response: HairAnalysisResponse) async -> Void {
        await MainActor.run {
            analysisProgress = "Finalizing analysis..."
        }
        
        // Use raw scores directly without conversion
        let hairRatings = HairRatings(
            thickness: response.ratings.thickness,
            health: response.ratings.health,
            scores: CategoryScores(
                moisture: response.ratings.scores.moisture,
                damage: response.ratings.scores.damage,
                texture: response.ratings.scores.texture,
                frizz: response.ratings.scores.frizz,
                shine: response.ratings.scores.shine,
                density: response.ratings.scores.density,
                elasticity: response.ratings.scores.elasticity
            )
        )
        
        // Calculate overall score using the weighted calculation
        let overallScore = calculateOverallScore(scores: hairRatings.scores)
        
        let analysis = HairAnalysis(
            ratings: hairRatings,
            overallScore: overallScore,
            recommendations: response.recommendations,
            date: Date()
        )
        
        if let userId = Auth.auth().currentUser?.uid {
            print("💾 Saving results...")
            try? await FirebaseService.shared.saveHairAnalysis(analysis, userId: userId)
            print("Analysis saved successfully")
        }
        
        await MainActor.run {
            self.hairAnalysis = analysis
            self.isAnalyzing = false
        }
    }
    
    private func calculateOverallScore(scores: CategoryScores) -> Int {
        // Weight the categories based on importance for hair health
        let weights: [String: Double] = [
            "moisture": 1.2,
            "damage": 1.3,
            "texture": 1.0,
            "frizz": 0.8,
            "shine": 0.7,
            "density": 0.9,
            "elasticity": 1.1
        ]
        
        // Calculate weighted sum using raw scores (1-100)
        let weightedSum = (
            Double(scores.moisture) * weights["moisture"]! +
            (100.0 - Double(scores.damage)) * weights["damage"]! +  // Invert damage score
            Double(scores.texture) * weights["texture"]! +
            (100.0 - Double(scores.frizz)) * weights["frizz"]! +   // Invert frizz score
            Double(scores.shine) * weights["shine"]! +
            Double(scores.density) * weights["density"]! +
            Double(scores.elasticity) * weights["elasticity"]!
        )
        
        // Calculate the actual maximum possible score
        let totalWeight = weights.values.reduce(0, +)
        let maxPossibleScore = 100.0 * totalWeight
        
        // Convert to 0-100 scale with a stronger boost for good scores
        var finalScore = (weightedSum / maxPossibleScore) * 100.0
        
        // Apply a stronger curve to boost scores
        if finalScore > 40 {
            let boost = (finalScore - 40) * 0.5  // 50% boost for scores above 40
            finalScore += boost
        }
        
        // Additional boost for very good scores
        if finalScore > 70 {
            let extraBoost = (finalScore - 70) * 0.2  // Extra 20% boost for scores above 70
            finalScore += extraBoost
        }
        
        // Ensure score stays within bounds
        return min(100, max(0, Int(round(finalScore))))
    }
    
    // Add helper function to convert 100-point scores to 5-star ratings for display
    private func convertToStarRating(_ score: Double) -> Double {
        // More generous conversion to 5-star scale
        let starScore = (score / 100.0) * 5.0
        
        // Boost lower scores a bit to make ratings appear more favorable
        if starScore > 2.0 {
            return min(5.0, starScore + 0.5)  // Add 0.5 stars to good scores
        } else {
            return max(1.0, starScore + 0.25)  // Add 0.25 stars to lower scores
        }
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
    let moisture: Double    // Now represents a value from 1-100
    let damage: Double     // Now represents a value from 1-100
    let texture: Double    // Now represents a value from 1-100
    let frizz: Double      // Now represents a value from 1-100
    let shine: Double      // Now represents a value from 1-100
    let density: Double    // Now represents a value from 1-100
    let elasticity: Double // Now represents a value from 1-100
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
