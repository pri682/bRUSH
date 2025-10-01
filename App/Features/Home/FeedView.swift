import SwiftUI
import Combine

// MARK: - Sorting
enum FeedSort: String, CaseIterable, Identifiable {
    case latest = "Latest"
    case top = "Top"
    case trending = "Trending"
    var id: String { rawValue }
}
struct FeedPost: Identifiable, Equatable {
    let id: UUID
    let itemID: UUID?
    let image: UIImage?
    let username: String
    let timestamp: Date
    var votes: Int
    var liked: Bool
    var commentsCount: Int

    init(itemID: UUID?, image: UIImage?, username: String, timestamp: Date, votes: Int, liked: Bool = false, commentsCount: Int = 0) {
        self.id = UUID()
        self.itemID = itemID
        self.image = image
        self.username = username
        self.timestamp = timestamp
        self.votes = votes
        self.liked = liked
        self.commentsCount = commentsCount
    }
}
