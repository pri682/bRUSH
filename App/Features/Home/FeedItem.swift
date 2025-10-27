import Foundation

struct FeedItem: Identifiable {
    let id: String               // Firestore document ID
    let userId: String           // UID of the user who made the post
    let firstName: String      // Full first name from /users/{uid}
    let displayName: String         // "@displayName" style handle
    let imageURL: String         // Firebase Storage image URL
    let medalGold: Int
    let medalSilver: Int
    let medalBronze: Int
    let date: String
    let createdAt: Date?
    
    // Profile image placeholder for UI
    var profileSystemImageName: String { "person.circle.fill" }
}
