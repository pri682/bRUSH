import Foundation

struct SentFriendRequest: Identifiable, Hashable {
    let id = UUID()
    let toName: String
    let toUid: String
    let handle: String
    let sentAt: Date = Date()
}
