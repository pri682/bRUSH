import Foundation

struct FriendSearchResult: Identifiable, Hashable {
    let id = UUID()
    let handle: String
    let displayName: String
}
