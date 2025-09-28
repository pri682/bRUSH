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
}
