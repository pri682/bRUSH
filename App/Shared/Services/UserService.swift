import Foundation
import FirebaseFirestore
import Combine

public struct UserProfile: Codable, Equatable {
    let uid: String
    let firstName: String
    let lastName: String
    let displayName: String
    let email: String
}

final class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private let usersCollection = "users"

    private init() {}

    func createProfile(userProfile: UserProfile) async throws {
        let uid = userProfile.uid
        let userRef = db.collection(usersCollection).document(uid)
        
        let profileData: [String: Any] = [
            "uid": uid,
            "firstName": userProfile.firstName,
            "lastName": userProfile.lastName,
            "displayName": userProfile.displayName,
            "email": userProfile.email.lowercased(),
            "createdAt": FieldValue.serverTimestamp()
        ]
        
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
        return try Firestore.Decoder().decode(UserProfile.self, from: data)
    }

}
