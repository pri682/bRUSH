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
struct FeedService {
    private let sampleNames = ["alex","sam","jordan","taylor","morgan","riley","casey","jamie","avery","kai","skye","remy","kit","rowan","harper","reese","sage","blake","drew","ari"]

    func buildPosts(from items: [Item]) -> [FeedPost] {
        var posts: [FeedPost] = []
        for (index, item) in items.enumerated() {
            let seed = item.id.hashValue
            let name = sampleNames[abs(seed + index) % sampleNames.count]
            let votes = abs(seed % 1000)
            let daysAgo = abs((seed >> 3) % 30)
            let minutesJitter = abs((seed >> 7) % 600)
            let timestamp = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
                .addingTimeInterval(-Double(minutesJitter * 60))
            posts.append(
                FeedPost(
                    itemID: item.id,
                    image: item.preview,
                    username: name,
                    timestamp: timestamp,
                    votes: votes,
                    liked: false,
                    commentsCount: abs((seed >> 5) % 120)
                )
            )
        }
        return posts
    }
    // MARK: - ViewModel
    @MainActor
    final class FeedViewModel: ObservableObject {
        @Published private(set) var visiblePosts: [FeedPost] = []
        @Published var sort: FeedSort = .latest { didSet { resetAndPaginate() } }
        @Published private(set) var isLoading: Bool = false
        @Published private(set) var hasMore: Bool = true

        private let pageSize: Int = 8
        private var allPosts: [FeedPost] = []
        private let service = FeedService()

        func rebuild(from items: [Item]) {
            allPosts = applySort(service.buildPosts(from: items), by: sort)
            resetAndPaginate()
        }

        func loadMoreIfNeeded(current post: FeedPost?) {
            guard let post else { return }
            if let threshold = visiblePosts.suffix(2).first, threshold.id == post.id {
                paginate()
            }
        }

        func toggleLike(for postID: UUID) {
            guard let idx = visiblePosts.firstIndex(where: { $0.id == postID }) else { return }
            visiblePosts[idx].liked.toggle()
            visiblePosts[idx].votes += visiblePosts[idx].liked ? 1 : -1
        }

        func incrementCommentCount(for postID: UUID) {
            if let i = visiblePosts.firstIndex(where: { $0.id == postID }) {
                visiblePosts[i].commentsCount += 1
            }
        }
