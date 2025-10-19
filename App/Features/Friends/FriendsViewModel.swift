import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

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
    
    private let handleService = HandleServiceFirebase()

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
        // require sign in to search users
        guard AuthService.shared.user != nil else {
                self.addResults = []
                self.addError = "Sign in to search for friends."
                return
            }
        
        let raw = addQuery
            .replacingOccurrences(of: "@", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard raw.count >= 2 else {
            addResults = []
            addError = nil
            return }
        
        isSearchingAdd = true
        addError = nil
        
    Task { @MainActor in
        do {
            let hits = try await handleService.searchHandles(prefix: raw, limit: 20)
            self.addResults = hits.map { hit in
                FriendSearchResult(uid: hit.uid, handle: hit.handle, displayName: hit.displayName)
            }
        }
        catch {
            self.addResults = []
            self.addError = "Search failed. Please try again."
        }
        self.isSearchingAdd = false
    }
}
    func sendFriendRequest(to user: FriendSearchResult) {
        let handle = "@\(user.handle)"
            guard !sent.contains(where: { $0.handle == handle }) else { return }
            sent.append(.init(toName: user.displayName, handle: handle))
      //  try await FriendRequestServiceFirebase().sendRequest(fromUid: me.id, fromHandle: myHandle, toUid: user.uid)
    }
    init() {
        $addQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.performAddSearch()
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
