import Foundation

struct FriendRequest: Identifiable {
    let id = UUID()
    let fromUid: String
    let fromName: String
    let handle: String
    let sentAt: Date = Date()
}
