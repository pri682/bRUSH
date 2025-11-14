import Foundation
import FirebaseFirestore
import Combine

public struct UserProfile: Codable, Equatable {
    let uid: String
    var firstName: String
    let lastName: String
    var displayName: String
    let email: String
    var avatarType: String // "fun" or "personal"
    var avatarBackground: String?
    var avatarBody: String?
    var avatarShirt: String?
    var avatarEyes: String?
    var avatarMouth: String?
    var avatarHair: String?
    var avatarFacialHair: String?
    
    // Medal and statistics fields
    var goldMedalsAccumulated: Int
    var silverMedalsAccumulated: Int
    var bronzeMedalsAccumulated: Int
    var goldMedalsAwarded: Int
    var silverMedalsAwarded: Int
    var bronzeMedalsAwarded: Int
    var totalDrawingCount: Int
    var streakCount: Int
    var memberSince: Date
}

final class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private let usersCollection = "users"

    private init() {}

    func createProfile(userProfile: UserProfile) async throws {
        let uid = userProfile.uid
        let userRef = db.collection(usersCollection).document(uid)
        
        var profileData: [String: Any] = [
            "uid": uid,
            "firstName": userProfile.firstName,
            "lastName": userProfile.lastName,
            "displayName": userProfile.displayName,
            "email": userProfile.email.lowercased(),
            "avatarType": userProfile.avatarType,
            "createdAt": FieldValue.serverTimestamp(),
            // Medal and statistics fields - initialized to 0
            "goldMedalsAccumulated": userProfile.goldMedalsAccumulated,
            "silverMedalsAccumulated": userProfile.silverMedalsAccumulated,
            "bronzeMedalsAccumulated": userProfile.bronzeMedalsAccumulated,
            "goldMedalsAwarded": userProfile.goldMedalsAwarded,
            "silverMedalsAwarded": userProfile.silverMedalsAwarded,
            "bronzeMedalsAwarded": userProfile.bronzeMedalsAwarded,
            "totalDrawingCount": userProfile.totalDrawingCount,
            "streakCount": userProfile.streakCount,
            "memberSince": userProfile.memberSince
        ]
        
        // Add avatar fields if they exist
        if let background = userProfile.avatarBackground {
            profileData["avatarBackground"] = background
        }
        if let body = userProfile.avatarBody {
            profileData["avatarBody"] = body
        }
        if let shirt = userProfile.avatarShirt {
            profileData["avatarShirt"] = shirt
        }
        if let eyes = userProfile.avatarEyes {
            profileData["avatarEyes"] = eyes
        }
        if let mouth = userProfile.avatarMouth {
            profileData["avatarMouth"] = mouth
        }
        if let hair = userProfile.avatarHair {
            profileData["avatarHair"] = hair
        }
        
        if let facialHair = userProfile.avatarFacialHair {
                    profileData["avatarFacialHair"] = facialHair
                }
        
        // This is the single critical database write
        try await userRef.setData(profileData)
    }
    
    func deleteProfile(uid: String) async throws {
        let userRef = db.collection(usersCollection).document(uid)
        try await userRef.delete()
    }
    
    func fetchProfile(uid: String) async throws -> UserProfile {
        let doc = try await db.collection(usersCollection).document(uid).getDocument()
        guard let data = doc.data() else {
            throw AuthError.backend("Profile not found.")
        }
        
        // Manual decoding to handle missing avatar fields in existing profiles
        guard let uid = data["uid"] as? String,
              let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let displayName = data["displayName"] as? String,
              let email = data["email"] as? String else {
            throw AuthError.backend("Invalid profile data.")
        }
        
        let avatarType = data["avatarType"] as? String ?? "personal" // Default to personal for existing profiles
        let avatarBackground = data["avatarBackground"] as? String
        let avatarBody = data["avatarBody"] as? String
        let avatarShirt = data["avatarShirt"] as? String
        let avatarEyes = data["avatarEyes"] as? String
        let avatarMouth = data["avatarMouth"] as? String
        let avatarHair = data["avatarHair"] as? String
        let avatarFacialHair = data["avatarFacialHair"] as? String
        
        // Medal and statistics fields - default to 0 if not present (for existing profiles)
        let goldMedalsAccumulated = data["goldMedalsAccumulated"] as? Int ?? 0
        let silverMedalsAccumulated = data["silverMedalsAccumulated"] as? Int ?? 0
        let bronzeMedalsAccumulated = data["bronzeMedalsAccumulated"] as? Int ?? 0
        let goldMedalsAwarded = data["goldMedalsAwarded"] as? Int ?? 0
        let silverMedalsAwarded = data["silverMedalsAwarded"] as? Int ?? 0
        let bronzeMedalsAwarded = data["bronzeMedalsAwarded"] as? Int ?? 0
        let totalDrawingCount = data["totalDrawingCount"] as? Int ?? 0
        let streakCount = data["streakCount"] as? Int ?? 0
        let memberSince = (data["memberSince"] as? Timestamp)?.dateValue() ?? Date()
        
        return UserProfile(
            uid: uid,
            firstName: firstName,
            lastName: lastName,
            displayName: displayName,
            email: email,
            avatarType: avatarType,
            avatarBackground: avatarBackground,
            avatarBody: avatarBody,
            avatarShirt: avatarShirt,
            avatarEyes: avatarEyes,
            avatarMouth: avatarMouth,
            avatarHair: avatarHair,
            avatarFacialHair: avatarFacialHair,
            goldMedalsAccumulated: goldMedalsAccumulated,
            silverMedalsAccumulated: silverMedalsAccumulated,
            bronzeMedalsAccumulated: bronzeMedalsAccumulated,
            goldMedalsAwarded: goldMedalsAwarded,
            silverMedalsAwarded: silverMedalsAwarded,
            bronzeMedalsAwarded: bronzeMedalsAwarded,
            totalDrawingCount: totalDrawingCount,
            streakCount: streakCount,
            memberSince: memberSince
        )
    }
    
    func updateProfile(uid: String, data: [String: Any]) async throws {
        let userRef = db.collection(usersCollection).document(uid)
        try await userRef.updateData(data)
    }
    
    // MARK: - Date Formatting Utility
    static func formatMemberSinceDate(_ date: Date) -> (year: String, monthDay: String) {
        let formatter = DateFormatter()
        
        // Get year
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        
        // Get month abbreviation and day
        formatter.dateFormat = "MMM d"
        let monthDay = formatter.string(from: date)
        
        return (year: year, monthDay: monthDay)
    }

}
