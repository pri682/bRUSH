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
    @Published var currentUserHandle: String?
    @Published var friendIds: Set<String> = []
    @Published var showingProfile: Bool = false
    @Published var selectedProfile: UserProfile? = nil
    @Published var selectedFriendUid: String? = nil
    @Published var medalCountsByUid: [String: (gold: Int, silver: Int, bronze: Int)] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private let handleService = HandleServiceFirebase()
    private let requestService = FriendRequestServiceFirebase()
    private var meUid: String? { AuthService.shared.user?.id }
    private var myHandle: String { currentUserHandle ?? AuthService.shared.user?.displayName ?? "unknown" }
    private let userService = UserService.shared
    
    private func hydrateFriendsFromIds() {
        self.friends = []
        let db = Firestore.firestore()
        let ids = Array(self.friendIds)
        // fetch each friend's profile (displayName) and append to `friends`
        for uid in ids {
            Task { @MainActor in
                do {
                    let doc = try await db.collection("users").document(uid).getDocument()
                    if let dn = doc.data()?["displayName"] as? String, !dn.isEmpty {
                        self.friends.append(Friend(uid: uid, name: dn, handle: "@\(dn)"))
                    } else {
                        // fallback if profile missing
                        self.friends.append(Friend(uid: uid, name: uid, handle: "@unknown"))
                    }
                } catch {
                    // ignore; leave friend out or append placeholder
                }
            }
        }
    }
    
    func refreshFriends() {
        guard let me = meUid else { friendIds = []; return }
        Task { @MainActor in
            do {
                let snap = try await Firestore.firestore()
                    .collection("friendships").document(me)
                    .collection("friends").getDocuments()
                self.friendIds = Set(snap.documents.map { $0.documentID })
                self.hydrateFriendsFromIds()
            } catch {
                // non-fatal; keep empty set
            }
        }
    }
    
    var filteredFriends: [Friend] {
        guard !searchText.isEmpty else { return friends }
        return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) ||
                                $0.handle.lowercased().contains(searchText.lowercased()) }
    }
    
    func loadMyHandle() {
        guard let me = meUid else { return }
        Task { @MainActor in
            do {
                let doc = try await Firestore.firestore()
                    .collection("users").document(me).getDocument()
                if let dn = doc.data()?["displayName"] as? String {
                    self.currentUserHandle = dn
                }
            } catch {
                // non-fatal; UI can still function with optimistic pending state
            }
        }
    }
    
    func accept(_ req: FriendRequest) {
        guard let me = meUid else { return }
        Task { @MainActor in
            do {
                try await requestService.accept(me: me, other: req.fromUid)
                requests.removeAll { $0.id == req.id }
                friends.append(Friend(uid: req.fromUid, name: req.fromName, handle: req.handle))
                refreshFriends()
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
            guard !friendIds.isEmpty else {
                self.leaderboard = []
                self.medalCountsByUid = [:]
                return
            }
            isLoadingLeaderboard = true
            leaderboardError = nil
            Task { @MainActor in
                do {
                    let db = Firestore.firestore()
                    let ids = Array(friendIds)
                    let chunkSize = 10
                    var allEntries: [LeaderboardEntry] = []
                    var medalMap: [String: (gold: Int, silver: Int, bronze: Int)] = [:]
                    
                    for start in stride(from: 0, to: ids.count, by: chunkSize) {
                                    let end = min(start + chunkSize, ids.count)
                                    let chunk = Array(ids[start..<end])

                                    let snap = try await db.collection("users")
                                        .whereField(FieldPath.documentID(), in: chunk)
                                        .getDocuments()

                                    for doc in snap.documents {
                                        let uid = doc.documentID
                                        let data = doc.data()

                                        let displayName = (data["displayName"] as? String) ?? "Unknown"
                                        // if handle is stored
                                        let handle = "@\(displayName)"

                                        let gold = (data["goldMedalsAccumulated"] as? Int) ?? 0
                                        let silver = (data["silverMedalsAccumulated"] as? Int) ?? 0
                                        let bronze = (data["bronzeMedalsAccumulated"] as? Int) ?? 0

                                        medalMap[uid] = (gold, silver, bronze)

                                        allEntries.append(
                                            LeaderboardEntry(
                                                uid: uid,
                                                displayName: displayName,
                                                handle: handle,
                                                gold: gold,
                                                silver: silver,
                                                bronze: bronze,
                                                submittedAt: Date()
                                        ))
                                    }
                                }
                                // Sort: points desc, then earlier submittedAt first
                                allEntries.sort {
                                    if $0.points != $1.points { return $0.points > $1.points }
                                    return $0.submittedAt < $1.submittedAt
                                }
                                self.leaderboard = allEntries
                                self.medalCountsByUid = medalMap
                } catch {
                    leaderboardError = "Failed to load leaderboard."
                }
                isLoadingLeaderboard = false
            }
        }
        func sendFriendRequest(to user: FriendSearchResult) {
            let handleLabel = "@\(user.handle)"
            guard !sent.contains(where: { $0.toUid == user.uid }) else { return }
            sent.append(.init(toName: user.displayName, toUid: user.uid, handle: handleLabel))
            guard let me = meUid else { return }
            let senderHandle = myHandle
            Task { @MainActor in
                do {
                    try await FriendRequestServiceFirebase().sendRequest(
                        fromUid: me,
                        fromHandle: senderHandle,
                        fromDisplay: senderHandle,
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
    func remove(friend: Friend) {
            guard let me = AuthService.shared.user?.id else { return }
            Task { @MainActor in
                do {
                    try await requestService.removeFriend(me: me, other: friend.uid)
                    // Locally drop it
                    if let idx = friends.firstIndex(of: friend) {
                        friends.remove(at: idx)
                    } else {
                        friends.removeAll { $0.uid == friend.uid }
                    }
                    friendIds.remove(friend.uid)
                    if !addQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        performAddSearch()
                    }
                    refreshFriends()
                } catch {
                    print("Failed to remove friend: \(error)")
                }
            }
        }
    func openProfile(for friend: Friend) {
            Task {
                do {
                    let profile = try await userService.fetchProfile(uid: friend.uid)
                    self.selectedProfile = profile
                    self.showingProfile = true
                } catch {
                    print("Failed to fetch profile: \(error)")
                }
            }
        }
    }
