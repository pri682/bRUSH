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
    @Published var currentUserFirstName: String?
    @Published var currentUserLastName: String?
    @Published var friendIds: Set<String> = []
    @Published var showingProfile: Bool = false
    @Published var selectedProfile: UserProfile? = nil
    @Published var selectedFriendUid: String? = nil
    @Published var medalCountsByUid: [String: (gold: Int, silver: Int, bronze: Int)] = [:]
    @Published var pendingOutgoing: Set<String> = []
    
    private var cancellables = Set<AnyCancellable>()
    private let handleService = HandleServiceFirebase()
    private let requestService = FriendRequestServiceFirebase()
    var meUid: String? { AuthService.shared.user?.id }
    private var myHandle: String { currentUserHandle ?? AuthService.shared.user?.displayName ?? "unknown" }
    private var myFullName: String {
        [currentUserFirstName, currentUserLastName].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
    }
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
                    let data = doc.data()
                    let dn = (data?["displayName"] as? String) ?? "unknown"
                    let fn = (data?["firstName"] as? String) ?? ""
                    let ln = (data?["lastName"] as? String) ?? ""
                    let fullName = [fn, ln].filter { !$0.isEmpty }.joined(separator: " ")
                    
                    self.friends.append(Friend(uid: uid, name: fullName.isEmpty ? dn : fullName, handle: "@\(dn)"))
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
    
    @MainActor
    func removeLocally(uids: [String]) {
        guard !uids.isEmpty else { return }
        let uidSet = Set(uids)
        // Update arrays synchronously
        friends.removeAll { uidSet.contains($0.uid) }
        friendIds.subtract(uidSet)
        
        // If Add Friend search is open, refresh badges
        if !addQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            performAddSearch()
        }
    }
        func removeRemote(uids: [String]) async {
            guard let me = AuthService.shared.user?.id, !uids.isEmpty else { return }
            for other in uids {
                do {
                    try await requestService.removeFriend(me: me, other: other)
                } catch {
                    print("Failed to remove friend remotely: \(other), error: \(error)")
                }
            }
            // light re-sync after animations settle
            await MainActor.run {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.refreshFriends()
                }
            }
        }
    
    func loadMyProfileData() {
        guard let me = meUid else { return }
        Task { @MainActor in
            do {
                let doc = try await Firestore.firestore()
                    .collection("users").document(me).getDocument()
                if let data = doc.data() {
                    self.currentUserHandle = data["displayName"] as? String
                    self.currentUserFirstName = data["firstName"] as? String
                    self.currentUserLastName = data["lastName"] as? String
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
    
    // This is the private search task
    private func searchTask(for query: String) async {
        // require sign in to search users
        guard AuthService.shared.user != nil else {
            await MainActor.run {
                self.addResults = []
                self.addError = "Sign in to search for friends."
                self.isSearchingAdd = false
            }
            return
        }
        
        let raw = query
            .replacingOccurrences(of: "@", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard raw.count >= 1 else {
            await MainActor.run {
                addResults = []
                addError = nil
                isSearchingAdd = false
            }
            return
        }
        
        // isSearchingAdd is already true from the sink.
        await MainActor.run {
            addError = nil
        }
        
        do {
            let hits = try await handleService.searchHandles(prefix: raw, limit: 20)
            
            await MainActor.run {
                self.addResults = hits.map { hit in
                    FriendSearchResult(uid: hit.uid, handle: hit.handle, fullName: hit.fullName)
                }
                pendingOutgoing = []
            }
            
            guard let me = meUid else {
                await MainActor.run { self.isSearchingAdd = false }
                return
            }

            // Check for pending requests for the results
            for hit in self.addResults {
                Task { @MainActor in
                    do {
                        if try await requestService.hasPending(fromUid: me, toUid: hit.uid) {
                            pendingOutgoing.insert(hit.uid)
                        }
                    } catch {
                        // ignore individual failures; row just won’t show “Pending”
                    }
                }
            }
            
        } catch {
            await MainActor.run {
                self.addResults = []
                self.addError = "Search failed. Please try again."
            }
        }
        
        // Set searching to false at the very end
        await MainActor.run {
            isSearchingAdd = false
        }
    }
    
    // This public function is for buttons (like onSubmit or manual refresh)
    func performAddSearch() {
        // Just run the task with the current query
        Task {
            await searchTask(for: addQuery)
        }
    }
    
    init() {
        $addQuery
            .removeDuplicates()
            .map { [weak self] query -> String in
                // This map operator runs *before* the debounce.
                // We set the searching state immediately.
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                Task { @MainActor in
                    // Show searching spinner if query is not empty
                    self?.isSearchingAdd = !trimmed.isEmpty
                    // Clear error and old results immediately
                    self?.addError = nil
                    if trimmed.isEmpty {
                        self?.addResults = []
                    }
                }
                return trimmed
            }
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] trimmedQuery in
                // This sink runs *after* the debounce.
                if trimmedQuery.isEmpty {
                    Task { @MainActor in
                        self?.addResults = []
                        self?.addError = nil
                        self?.isSearchingAdd = false // Turn off spinner
                    }
                } else {
                    // Run the actual search
                    Task {
                        await self?.searchTask(for: trimmedQuery)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func loadLeaderboard(for date: Date = Date()) {
            isLoadingLeaderboard = true
            leaderboardError = nil
            Task { @MainActor in
                do {
                    let db = Firestore.firestore()
                    var ids = Array(friendIds)
                    if let me = meUid {
                        ids.append(me)
                    }
                    guard !ids.isEmpty else {
                        leaderboard = []
                        isLoadingLeaderboard = false
                        return
                    }
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
                                        let fn = (data["firstName"] as? String) ?? ""
                                        let ln = (data["lastName"] as? String) ?? ""
                                        let fullName = [fn, ln].filter { !$0.isEmpty }.joined(separator: " ")
                                        
                                        let handle = "@\(displayName)"

                                        let gold = (data["goldMedalsAccumulated"] as? Int) ?? 0
                                        let silver = (data["silverMedalsAccumulated"] as? Int) ?? 0
                                        let bronze = (data["bronzeMedalsAccumulated"] as? Int) ?? 0

                                        medalMap[uid] = (gold, silver, bronze)

                                        allEntries.append(
                                            LeaderboardEntry(
                                                uid: uid,
                                                fullName: fullName.isEmpty ? displayName : fullName,
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
            sent.append(.init(toName: user.fullName, toUid: user.uid, handle: handleLabel))
            guard let me = meUid else { return }
            let senderHandle = myHandle
            let senderDisplay = myFullName
            
            pendingOutgoing.insert(user.uid)
            Task { @MainActor in
                do {
                    try await FriendRequestServiceFirebase().sendRequest(
                        fromUid: me,
                        fromHandle: senderHandle,
                        fromDisplay: senderDisplay.isEmpty ? senderHandle : senderDisplay,
                        toUid: user.uid)
                }
                catch {
                    sent.removeAll { $0.handle == handleLabel }
                    pendingOutgoing.remove(user.uid)
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
    func isRequestPending(uid: String) -> Bool {
        pendingOutgoing.contains(uid)
    }
    func resetSessionData() {
        friends = []
        requests = []
        sent = []
        pendingOutgoing = []
        addResults = []
        addQuery = ""
    }
    }
