import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {
        // Initialize Firebase if not already initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    // MARK: - Hair Analysis Methods
    
    func saveHairAnalysis(_ analysis: HairAnalysis, userId: String) async throws {
        let data: [String: Any] = [
            "thickness": analysis.thickness,
            "health": analysis.health,
            "recommendations": analysis.recommendations,
            "date": analysis.date,
            "userId": userId
        ]
        
        try await db.collection("hairAnalyses").document().setData(data)
    }
    
    func getHairAnalyses(for userId: String) async throws -> [HairAnalysis] {
        let snapshot = try await db.collection("hairAnalyses")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard let thickness = data["thickness"] as? String,
                  let health = data["health"] as? String,
                  let recommendations = data["recommendations"] as? [String],
                  let date = (data["date"] as? Timestamp)?.dateValue() else {
                return nil
            }
            
            return HairAnalysis(
                thickness: thickness,
                health: health,
                recommendations: recommendations,
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
} 