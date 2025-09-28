import Foundation
import FirebaseFirestore
import Combine

// Helper struct for what we store in Firestore (User Document)
// We remove @DocumentID and rely on the explicit 'uid' to be the document ID.
public struct UserProfile: Codable, Equatable {
    // ❌ Removed @DocumentID var id: String?
    let uid: String              // Firebase Auth UID, which we will use as the Document ID
    let firstName: String
    let lastName: String
    let displayName: String
    let email: String
    
    // CodingKeys can be used to control the field names if needed, but omitted for simplicity
    // If you need to map a Firestore field name to a different Swift property name, use CodingKeys.
}

// Dedicated service for non-Auth user data
final class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private let displayNamesCollection = "displayNames"

    private init() {}

    // 1. Checks if a display name is already taken
    func isDisplayNameTaken(_ displayName: String) async throws -> Bool {
        let normalizedName = displayName.lowercased()
        let ref = db.collection(displayNamesCollection).document(normalizedName)
        
        // Fetch the document; if it exists, the name is taken.
        let snapshot = try await ref.getDocument()
        return snapshot.exists
    }

    // 2. Completes the profile and saves all user details using a batch write
    func createProfile(userProfile: UserProfile) async throws {
        let uid = userProfile.uid
        
        // Use a batch to ensure atomicity: either both succeed or both fail.
        let batch = db.batch()

        // 2a. Add/Update the main user profile document
        // We manually specify the UID as the document ID here (userRef.document(uid))
        let userRef = db.collection(usersCollection).document(uid)
        
        // Use standard dictionary encoding since we aren't using FirestoreSwift Codable helpers
        let profileData: [String: Any] = [
            "uid": uid,
            "firstName": userProfile.firstName,
            "lastName": userProfile.lastName,
            "displayName": userProfile.displayName,
            "email": userProfile.email.lowercased(),
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        batch.setData(profileData, forDocument: userRef)
        
        // 2b. Save the unique display name "lock"
        let normalizedName = userProfile.displayName.lowercased()
        let nameRef = db.collection(displayNamesCollection).document(normalizedName)
        
        // Store the UID associated with the display name for indexing/lookup
        batch.setData(["uid": uid, "timestamp": FieldValue.serverTimestamp()], forDocument: nameRef)

        // Commit the batch to execute both writes
        try await batch.commit()
    }
}
