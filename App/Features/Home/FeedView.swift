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
    var userVote: Int
    var medalsCount: Int
    var medaled: Bool
    var commentsCount: Int

    init(itemID: UUID?, image: UIImage?, username: String, timestamp: Date, votes: Int, userVote: Int = 0, commentsCount: Int = 0, medalsCount: Int = 0, medaled: Bool = false) {
        self.id = UUID()
        self.itemID = itemID
        self.image = image
        self.username = username
        self.timestamp = timestamp
        self.votes = votes
        self.userVote = userVote
        self.medalsCount = medalsCount
        self.medaled = medaled
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
                    userVote: 0,
                    commentsCount: abs((seed >> 5) % 120),
                    medalsCount: abs((seed >> 9) % 30),
                    medaled: false
                )
            )
        }
        return posts
    }
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
        
        func upvote(postID: UUID) {
            guard let idx = visiblePosts.firstIndex(where: { $0.id == postID }) else { return }
            let current = visiblePosts[idx].userVote
            switch current {
            case 1:
                visiblePosts[idx].userVote = 0
                visiblePosts[idx].votes -= 1
            case -1:
                visiblePosts[idx].userVote = 1
                visiblePosts[idx].votes += 2
            default:
                visiblePosts[idx].userVote = 1
                visiblePosts[idx].votes += 1
            }
        }
        
        func downvote(postID: UUID) {
            guard let idx = visiblePosts.firstIndex(where: { $0.id == postID }) else { return }
            let current = visiblePosts[idx].userVote
            switch current {
            case -1:
                visiblePosts[idx].userVote = 0
                visiblePosts[idx].votes += 1
            case 1:
                visiblePosts[idx].userVote = -1
                visiblePosts[idx].votes -= 2
            default:
                visiblePosts[idx].userVote = -1
                visiblePosts[idx].votes -= 1
            }
        }
        
        func awardMedal(postID: UUID) {
            guard let idx = visiblePosts.firstIndex(where: { $0.id == postID }) else { return }
            guard !visiblePosts[idx].medaled else { return }
            visiblePosts[idx].medaled = true
            visiblePosts[idx].medalsCount += 1
        }
        
        func incrementCommentCount(for postID: UUID) {
            if let i = visiblePosts.firstIndex(where: { $0.id == postID }) {
                visiblePosts[i].commentsCount += 1
            }
        }
        
        private func resetAndPaginate() {
            isLoading = false
            hasMore = true
            visiblePosts.removeAll()
            paginate()
        }
        
        private func paginate() {
            guard !isLoading, hasMore else { return }
            isLoading = true
            let start = visiblePosts.count
            let end = min(start + pageSize, allPosts.count)
            if start < end { visiblePosts.append(contentsOf: allPosts[start..<end]) }
            hasMore = end < allPosts.count
            isLoading = false
        }
        
        private func applySort(_ posts: [FeedPost], by sort: FeedSort) -> [FeedPost] {
            switch sort {
            case .latest:
                return posts.sorted { $0.timestamp > $1.timestamp }
            case .top:
                return posts.sorted { $0.votes > $1.votes }
            case .trending:
                func score(_ p: FeedPost) -> Double {
                    let hours: Double = Date().timeIntervalSince(p.timestamp) / 3600.0
                    let denom: Double = pow(hours + 2.0, 0.7)
                    return Double(p.votes) / max(1.0, denom)
                }
                return posts.sorted { score($0) > score($1) }
            }
        }
    }
    struct FeedView: View {
        @EnvironmentObject private var dataModel: DataModel
        @StateObject private var viewModel = FeedViewModel()
        
        @State private var showComments = false
        @State private var selectedPostForComments: FeedPost?
        
        @State private var showProfile = false
        @State private var selectedUsername: String?
        
        // Prebuild gradient with the iOS-wide initializer to avoid “no exact matches”
        private let storiesGradient = LinearGradient(
            gradient: Gradient(colors: [BrushTheme.pink, BrushTheme.orange]),
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        
        private let peopleNames = ["Alex","Sam","Jordan","Taylor","Morgan","Riley","Casey","Jamie","Avery","Kai"]
        
        var body: some View {
            ZStack {
                HomeBackground(palette: HomeBackground.brandVivid).ignoresSafeArea()
                content
                
                NavigationLink(isActive: $showProfile, destination: {
                    ProfileView(username: selectedUsername ?? "User")
                }, label: {
                    EmptyView()
                })
                .hidden()
            }
            .onAppear { viewModel.rebuild(from: dataModel.items) }
            .onChange(of: dataModel.items) { _, newItems in
                viewModel.rebuild(from: newItems)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: CGFloat(8)) {
                        BrandIcon(size: CGFloat(22), preferAsset: true)
                        Text("Brush")
                            .font(BrushFont.title(CGFloat(22)))
                            .foregroundStyle(BrushTheme.textBlue)
                    }
                }
            }
            .refreshable { viewModel.rebuild(from: dataModel.items) }
            .sheet(isPresented: $showComments) {
                if let post = selectedPostForComments {
                    CommentsSheet(
                        postUsername: post.username,
                        initialCount: post.commentsCount
                    ) { _ in
                        viewModel.incrementCommentCount(for: post.id)
                    }
                }
            }
        }
        
        private var content: some View {
            ScrollView {
                VStack(spacing: CGFloat(0)) {
                    storiesRow
                        .padding(.vertical, CGFloat(8))
                        .padding(.leading, CGFloat(8))
                    
                    sortControl
                        .padding(.horizontal)
                        .padding(.bottom, CGFloat(8))
                    
                    LazyVStack(spacing: CGFloat(16)) {
                        ForEach(viewModel.visiblePosts) { post in
                            PostCard(
                                post: post,
                                upvoteTapped: { viewModel.upvote(postID: post.id) },
                                downvoteTapped: { viewModel.downvote(postID: post.id) },
                                medalTapped: { viewModel.awardMedal(postID: post.id) },
                                commentsTapped: {
                                    selectedPostForComments = post
                                    showComments = true
                                },
                                profileTapped: { selectedUsername = post.username; showProfile = true }
                            )
                            .onAppear { viewModel.loadMoreIfNeeded(current: post) }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView().padding()
                        } else if !viewModel.hasMore && viewModel.visiblePosts.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal, CGFloat(12))
                    .padding(.bottom, CGFloat(24))
                }
            }
        }
        
        private var sortControl: some View {
            Picker("Sort", selection: $viewModel.sort) {
                ForEach(FeedSort.allCases) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)
        }
        
        private var storiesRow: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CGFloat(14)) {
                    ForEach(Array(peopleNames.enumerated()), id: \.offset) { pair in
                        let idx = pair.offset
                        let name = pair.element
                        Button(action: { selectedUsername = name; showProfile = true }) {
                            VStack(spacing: CGFloat(6)) {
                                Circle()
                                    .fill(storiesGradient)
                                    .frame(width: CGFloat(64), height: CGFloat(64))
                                    .overlay(Circle().stroke(Color.white, lineWidth: CGFloat(3)))
                                    .shadow(color: Color.black.opacity(0.08), radius: CGFloat(6), y: CGFloat(3))
                                Text(name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CGFloat(8))
            }
        }
        
        private var emptyState: some View {
            VStack(spacing: 12) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("No posts yet")
                    .font(.headline)
                    .foregroundStyle(BrushTheme.textBlue)
                Text("Create a drawing to see it here, or check back soon.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .brushGlass(cornerRadius: 16)
        }
    }
    #Preview {
        NavigationStack { FeedView() }
            .environmentObject(DataModel())
    }

