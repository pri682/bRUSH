import Foundation

struct FriendSearchResult: Identifiable, Hashable {
    let id = UUID()
    let uid: String
    let handle: String
    let fullName: String
}
