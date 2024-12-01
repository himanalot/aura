import Foundation

struct ReferralCode: Codable, Identifiable {
    let id: String
    let ownerId: String
    let code: String
    let usedBy: [String]
    let createdAt: Date
    
    var isValid: Bool {
        usedBy.count < 2  // Requires 2 referrals
    }
}

struct UserReferralStatus: Codable {
    let referralCode: String?
    let usedReferralCode: String?
    let availableAnalyses: Int
} 