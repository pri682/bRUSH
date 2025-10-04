import Foundation

struct SentFriendRequest: Identifiable, Hashable {
    let id = UUID()
    let toName: String
    let handle: String
    let sentAt: Date = Date()
}
