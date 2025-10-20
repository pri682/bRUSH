import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var searchText: String = ""
    @Published var requests: [FriendRequest] = []
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
    private let requestService = FriendRequestServiceFirebase()
    private var meUid: String? { AuthService.shared.user?.id }
    private var myHandle: String { AuthService.shared.user?.displayName ?? "unknown" }

    var filteredFriends: [Friend] {
        guard !searchText.isEmpty else { return friends }
        return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) ||
                                $0.handle.lowercased().contains(searchText.lowercased()) }
    }
    func accept(_ req: FriendRequest) {
        guard let me = meUid else { return }
        Task { @MainActor in
            do {
                try await requestService.accept(me: me, other: req.fromUid)
                requests.removeAll { $0.id == req.id }
                friends.append(Friend(name: req.fromName, handle: req.handle))
            }
            catch {
                addError = "Failed to accept friend request."
            }
        }
    }
    func decline(_ req: FriendRequest) {
        guard let me = meUid else { return }
        Task { @MainActor in
            do {
                try await requestService.decline(me: me, other: req.fromUid)
                requests.removeAll { $0.id == req.id }
            } catch {
                addError = "Failed to decline friend request."
            }
        }
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
        func sendFriendRequest(to user: FriendSearchResult) {
            let handleLabel = "@\(user.handle)"
            guard !sent.contains(where: { $0.handle == handleLabel }) else { return }
            sent.append(.init(toName: user.displayName, handle: handleLabel))
            guard let me = meUid else { return }
            Task { @MainActor in
                do {
                    try await FriendRequestServiceFirebase().sendRequest(
                        fromUid: me,
                        fromHandle: myHandle,
                        fromDisplay: myHandle,
                        toUid: user.uid)
                }
                catch {
                    sent.removeAll { $0.handle == handleLabel }
                    addError = "Failed to send friend request."
                }
            }
        }
        func refreshIncoming() {
            guard let me = meUid else {
                self.requests = []
                return
            }
            Task { @MainActor in
                do {
                    let dtos = try await requestService.fetchIncoming(forUid: me)
                    self.requests = dtos.map { dto in
                        FriendRequest(
                            fromUid: dto.fromUid,
                            fromName: dto.fromDisplay.isEmpty ? dto.fromHandle : dto.fromDisplay,
                            handle: dto.fromHandle
                        )
                    }
                } catch {
                    addError = "Failed to load friend requests."
                }
            }
        }
    }
