import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    // MARK: - Hair Analysis Methods
    
    func saveHairAnalysis(_ analysis: HairAnalysis, userId: String) async throws {
        let data: [String: Any] = [
            "ratings": [
                "thickness": analysis.ratings.thickness,
                "health": analysis.ratings.health,
                "scores": [
                    "moisture": analysis.ratings.scores.moisture,
                    "damage": analysis.ratings.scores.damage,
                    "texture": analysis.ratings.scores.texture,
                    "frizz": analysis.ratings.scores.frizz,
                    "shine": analysis.ratings.scores.shine,
                    "density": analysis.ratings.scores.density,
                    "elasticity": analysis.ratings.scores.elasticity
                ]
            ],
            "overallScore": analysis.overallScore,
            "recommendations": [
                "products": analysis.recommendations.products.map { [
                    "category": $0.category,
                    "name": $0.name,
                    "reason": $0.reason
                ] },
                "techniques": analysis.recommendations.techniques,
                "lifestyle": analysis.recommendations.lifestyle
            ],
            "date": FirebaseFirestore.Timestamp(date: analysis.date),
            "userId": userId
        ]
        
        try await db.collection("hairAnalyses").document().setData(data)
    }
    
    func fetchHairAnalyses(userId: String) async throws -> [HairAnalysis] {
        let snapshot = try await db.collection("hairAnalyses")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            let data = document.data()
            
            guard let ratingsData = data["ratings"] as? [String: Any],
                  let thickness = ratingsData["thickness"] as? String,
                  let health = ratingsData["health"] as? String,
                  let scoresData = ratingsData["scores"] as? [String: Double],
                  let recommendationsData = data["recommendations"] as? [String: Any],
                  let productsData = recommendationsData["products"] as? [[String: String]],
                  let techniques = recommendationsData["techniques"] as? [String],
                  let lifestyle = recommendationsData["lifestyle"] as? [String],
                  let overallScore = data["overallScore"] as? Int,
                  let timestamp = data["date"] as? FirebaseFirestore.Timestamp else {
                throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid document format"])
            }
            
            let date = timestamp.dateValue()
            
            let scores = CategoryScores(
                moisture: scoresData["moisture"] ?? 0,
                damage: scoresData["damage"] ?? 0,
                texture: scoresData["texture"] ?? 0,
                frizz: scoresData["frizz"] ?? 0,
                shine: scoresData["shine"] ?? 0,
                density: scoresData["density"] ?? 0,
                elasticity: scoresData["elasticity"] ?? 0
            )
            
            let products = productsData.map { productData in
                ProductRecommendation(
                    category: productData["category"] ?? "",
                    name: productData["name"] ?? "",
                    reason: productData["reason"] ?? ""
                )
            }
            
            return HairAnalysis(
                ratings: HairRatings(
                    thickness: thickness,
                    health: health,
                    scores: scores
                ),
                overallScore: overallScore,
                recommendations: Recommendations(
                    products: products,
                    techniques: techniques,
                    lifestyle: lifestyle
                ),
                date: date
            )
        }
    }
    
    // MARK: - Image Storage Methods
    
    func uploadImage(_ image: UIImage, userId: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let filename = "\(userId)/\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("hair_images/\(filename)")
        
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL
    }
    
    // Add this method
    func saveDiagnosticResults(_ results: DiagnosticResults) async throws {
        let data: [String: Any] = [
            "answers": results.answers,
            "date": results.date,
            "userId": results.userId
        ]
        
        try await db.collection("diagnostics").document().setData(data)
    }
    
    func fetchLatestDiagnosticResults(userId: String) async throws -> DiagnosticResults? {
        let snapshot = try await db.collection("diagnostics")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            return nil
        }
        
        let data = document.data()
        guard let answers = data["answers"] as? [String: String],
              let date = (data["date"] as? FirebaseFirestore.Timestamp)?.dateValue(),
              let userId = data["userId"] as? String else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid document format"])
        }
        
        return DiagnosticResults(answers: answers, date: date, userId: userId)
    }
    
    func generateReferralCode(for userId: String) async throws -> ReferralCode {
        let code = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
        
        let referralCode = ReferralCode(
            id: UUID().uuidString,
            ownerId: userId,
            code: code,
            usedBy: [],
            createdAt: Date()
        )
        
        try await db.collection("referralCodes").document(referralCode.id).setData([
            "ownerId": referralCode.ownerId,
            "code": referralCode.code,
            "usedBy": referralCode.usedBy,
            "createdAt": FirebaseFirestore.Timestamp(date: referralCode.createdAt)
        ])
        
        return referralCode
    }
    
    func useReferralCode(_ code: String, by userId: String) async throws {
        let snapshot = try await db.collection("referralCodes")
            .whereField("code", isEqualTo: code)
            .getDocuments()
        
        guard let document = snapshot.documents.first,
              var referralCode = try? document.data(as: ReferralCode.self),
              referralCode.isValid,
              !referralCode.usedBy.contains(userId) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid referral code"])
        }
        
        try await document.reference.updateData([
            "usedBy": FieldValue.arrayUnion([userId])
        ])
        
        // Give free analyses to both users
        try await updateAvailableAnalyses(userId: userId, increment: 1)
        try await updateAvailableAnalyses(userId: referralCode.ownerId, increment: 1)
    }
    
    func updateAvailableAnalyses(userId: String, increment: Int) async throws {
        let ref = db.collection("users").document(userId)
        try await ref.setData([
            "availableAnalyses": FieldValue.increment(Int64(increment))
        ], merge: true)
    }
    
    func getReferralStatus(userId: String) async throws -> UserReferralStatus {
        let userDoc = try await db.collection("users").document(userId).getDocument()
        let data = userDoc.data() ?? [:]
        
        return UserReferralStatus(
            referralCode: data["referralCode"] as? String,
            usedReferralCode: data["usedReferralCode"] as? String,
            availableAnalyses: data["availableAnalyses"] as? Int ?? 0
        )
    }
} 