import Foundation

struct ReferralCode: Codable, Identifiable {
    let id: String
    let ownerId: String
    let code: String
    let usedBy: [String]
    let createdAt: Date
    
    var isValid: Bool {
        usedBy.count < 1  // Changed from 2 to 1 required referral
    }
}

struct UserReferralStatus: Codable {
    let referralCode: String?
    let usedReferralCode: String?
    let availableAnalyses: Int
} 