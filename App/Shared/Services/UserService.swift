import Foundation
import FirebaseFirestore
import Combine

public struct UserProfile: Codable, Equatable {
    let uid: String
    var firstName: String
    let lastName: String
    var displayName: String
    let email: String
    var avatarFace: String?
    var avatarEyes: String?
    var avatarMouth: String?
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
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        // Add avatar fields if they exist
        if let face = userProfile.avatarFace {
            profileData["avatarFace"] = face
        }
        if let eyes = userProfile.avatarEyes {
            profileData["avatarEyes"] = eyes
        }
        if let mouth = userProfile.avatarMouth {
            profileData["avatarMouth"] = mouth
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
        
        let avatarFace = data["avatarFace"] as? String
        let avatarEyes = data["avatarEyes"] as? String
        let avatarMouth = data["avatarMouth"] as? String
        
        return UserProfile(
            uid: uid,
            firstName: firstName,
            lastName: lastName,
            displayName: displayName,
            email: email,
            avatarFace: avatarFace,
            avatarEyes: avatarEyes,
            avatarMouth: avatarMouth
        )
    }
    
    func updateProfile(uid: String, data: [String: Any]) async throws {
        let userRef = db.collection(usersCollection).document(uid)
        try await userRef.updateData(data)
    }

}
