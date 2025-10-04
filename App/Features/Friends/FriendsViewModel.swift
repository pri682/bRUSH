import Foundation
import SwiftUI
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var searchText: String = ""
    @Published var requests: [FriendRequest] = [
        FriendRequest(fromName: "Marcus", handle: "@m.aurelius"),
        FriendRequest(fromName: "Taylor",   handle: "@tswift22")
    ]
    @Published var addQuery: String = ""
    @Published var addResults: [FriendSearchResult] = []
    @Published var isSearchingAdd: Bool = false
    @Published var addError: String?
    @Published var sent: [SentFriendRequest] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var isLoadingLeaderboard = false
    @Published var leaderboardError: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var leaderboardService: LeaderboardService = FriendsLeaderboardServiceStub()
    
    private let _mockDirectory: [FriendSearchResult] = [
        .init(handle: "jesse",  displayName: "Jesse Flynn"),
        .init(handle: "kelvin",  displayName: "Kelvin Mathew"),
        .init(handle: "priyanka", displayName: "Priyanka Karki"),
        .init(handle: "vaidic",  displayName: "Vaidic Soni"),
        .init(handle: "meidad",  displayName: "Meidad Troper")
    ]
    func loadMock() {
        friends = [
            Friend(name: "Ted", handle: "@grumpyoldman"),
            Friend(name: "Aaron", handle: "@lunchalone"),
            Friend(name: "Jeffrey", handle: "@dahmer")
        ]
    }
    var filteredFriends: [Friend] {
        guard !searchText.isEmpty else { return friends }
        return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) ||
                                $0.handle.lowercased().contains(searchText.lowercased()) }
    }
    func accept(_ req: FriendRequest) {
        friends.append(Friend(name: req.fromName, handle: req.handle))
        requests.removeAll { $0.id == req.id }
    }
    func decline(_ req: FriendRequest) {
        requests.removeAll { $0.id == req.id }
    }
    func performAddSearch() {
        let raw = addQuery
            .replacingOccurrences(of: "@", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !raw.isEmpty else {
            addResults = []
            return
        }
        isSearchingAdd = true
        addError = nil

        addResults = _mockDirectory
            .filter { $0.handle.contains(raw) }
            .sorted { $0.handle < $1.handle }

        isSearchingAdd = false
    }
    func sendFriendRequest(to user: FriendSearchResult) {
        let handle = "@\(user.handle)"
            guard !sent.contains(where: { $0.handle == handle }) else { return }
            sent.append(.init(toName: user.displayName, handle: handle))
            print("Sent friend request to \(handle)")
    }
    init() {
        $addQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] q in
                guard let self else { return }
                let trimmed = q.replacingOccurrences(of: "@", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count >= 2 {
                    self.isSearchingAdd = true
                    self.addResults = self._mockDirectory
                        .filter { $0.handle.contains(trimmed.lowercased()) }
                        .sorted { $0.handle < $1.handle }
                    self.isSearchingAdd = false
                } else {
                    self.addResults = []
                }
            }
            .store(in: &cancellables)
        }
    func loadLeaderboard(for date: Date = Date()) {
        isLoadingLeaderboard = true
        leaderboardError = nil
        Task { @MainActor in
            do {
                let entries = try await leaderboardService.fetchLeaderboard(for: date)
                self.leaderboard = entries.sorted {
                    if $0.points != $1.points {
                        return $0.points > $1.points
                    }
                    return $0.submittedAt < $1.submittedAt
                }
            } catch {
                leaderboardError = "Failed to load leaderboard."
            }
            isLoadingLeaderboard = false
        }
    }
}
