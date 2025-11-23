import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [UserProfile] = []
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
    @Published var currentUser: UserProfile?
    @Published var friendIds: Set<String> = []
    @Published var showingProfile: Bool = false
    @Published var selectedProfile: UserProfile? = nil
    @Published var selectedFriendUid: String? = nil
    @Published var medalCountsByUid: [String: (gold: Int, silver: Int, bronze: Int)] = [:]
    @Published var pendingOutgoing: Set<String> = []
    
    private var cancellables = Set<AnyCancellable>()
    private let handleService = HandleServiceFirebase()
    private let requestService = FriendRequestServiceFirebase()
    private let notificationManager = NotificationManager.shared // New: Shared instance for notifications
    var meUid: String? { AuthService.shared.user?.id }
    
    private var myHandle: String { currentUser?.displayName ?? AuthService.shared.user?.displayName ?? "unknown" }
    private var myFullName: String {
        guard let user = currentUser else { return "" }
        return [user.firstName, user.lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }
    private let userService = UserService.shared
    
    // New: Deinit to clean up the listener
    deinit {
        requestService.stopListeningForIncoming()
    }
    
    private func hydrateFriendsFromIds() {
        self.friends = []
        let ids = Array(self.friendIds)
        Task { @MainActor in
            var loadedProfiles: [UserProfile] = []
            for uid in ids {
                do {
                    let profile = try await userService.fetchProfile(uid: uid)
                    loadedProfiles.append(profile)
                } catch {
                    // handle error silently or log
                }
            }
            self.friends = loadedProfiles.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
            
            // Automatically update leaderboard if we have data
            if !leaderboard.isEmpty {
                loadLeaderboard()
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
            }
        }
    }
    
    var filteredFriends: [UserProfile] {
        guard !searchText.isEmpty else { return friends }
        return friends.filter {
            let name = [$0.firstName, $0.lastName].filter { !$0.isEmpty }.joined(separator: " ")
            return name.localizedCaseInsensitiveContains(searchText) ||
                   $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    @MainActor
    func removeLocally(uids: [String]) {
        guard !uids.isEmpty else { return }
        let uidSet = Set(uids)
        friends.removeAll { uidSet.contains($0.uid) }
        friendIds.subtract(uidSet)
        
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
                self.currentUser = try await userService.fetchProfile(uid: me)
            } catch {
            }
        }
    }
    
    func accept(_ req: FriendRequest) {
        guard let me = meUid else { return }
        Task { @MainActor in
            do {
                try await requestService.accept(me: me, other: req.fromUid)
                requests.removeAll { $0.id == req.id }
                // Fetch the new friend profile
                if let newProfile = try? await userService.fetchProfile(uid: req.fromUid) {
                    friends.append(newProfile)
                    refreshFriends()
                }
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
    
    private func searchTask(for query: String) async {
        guard let me = meUid else {
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
        
        await MainActor.run {
            addError = nil
        }
        
        do {
            let hits = try await handleService.searchHandles(prefix: raw, limit: 20)
            
            let searchResults = hits.map { FriendSearchResult(uid: $0.uid, handle: $0.handle, fullName: $0.fullName) }
            var newPendingOutgoing: Set<String> = []

            await withTaskGroup(of: (String, Bool).self) { group in
                for hit in searchResults {
                    group.addTask {
                        let isPending = (try? await self.requestService.hasPending(fromUid: me, toUid: hit.uid)) ?? false
                        return (hit.uid, isPending)
                    }
                }
                
                for await (uid, isPending) in group {
                    if isPending {
                        newPendingOutgoing.insert(uid)
                    }
                }
            }

            await MainActor.run {
                self.addResults = searchResults
                self.pendingOutgoing = newPendingOutgoing
                self.isSearchingAdd = false
            }
            
        } catch {
            await MainActor.run {
                self.addResults = []
                self.addError = "Search failed. Please try again."
                self.isSearchingAdd = false
            }
        }
    }
    
    func performAddSearch() {
        Task {
            await searchTask(for: addQuery)
        }
    }
    
    init() {
        $addQuery
            .removeDuplicates()
            .map { [weak self] query -> String in
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                Task { @MainActor in
                    self?.isSearchingAdd = !trimmed.isEmpty
                    self?.addError = nil
                    if trimmed.isEmpty {
                        self?.addResults = []
                    }
                }
                return trimmed
            }
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] trimmedQuery in
                if trimmedQuery.isEmpty {
                    Task { @MainActor in
                        self?.addResults = []
                        self?.addError = nil
                        self?.isSearchingAdd = false
                    }
                } else {
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
        
        var allProfiles = friends
        if let me = currentUser {
            // Avoid duplicates
            if !allProfiles.contains(where: { $0.uid == me.uid }) {
                allProfiles.append(me)
            }
        }
        
        let entries = allProfiles.map { LeaderboardEntry(profile: $0) }
        
        // Sort by points desc
        self.leaderboard = entries.sorted {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.fullName < $1.fullName
        }
        
        // Populate medal counts for quick lookup if needed
        var medalMap: [String: (gold: Int, silver: Int, bronze: Int)] = [:]
        for entry in entries {
            medalMap[entry.uid] = (entry.gold, entry.silver, entry.bronze)
        }
        self.medalCountsByUid = medalMap
        
        isLoadingLeaderboard = false
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
    
    // 💡 FIX: Replaced one-time fetch with a real-time listener that triggers notifications
    func refreshIncoming() {
        guard let me = meUid else {
            requestService.stopListeningForIncoming()
            self.requests = []
            return
        }
        
        // Start the real-time listener
        requestService.startListeningForIncoming(forUid: me) { [weak self] dtos in
            Task { @MainActor in
                guard let self = self else { return }
                
                var hydratedRequests: [FriendRequest] = []
                
                // Track UIDs for requests currently known to the ViewModel (before this update)
                let existingRequestUids = Set(self.requests.map { $0.fromUid })
                var newRequestProfiles: [FriendRequest] = [] // Requests found in this snapshot that were NOT in the last one

                // 2. Hydrate profiles in parallel using TaskGroup
                await withTaskGroup(of: FriendRequest?.self) { group in
                    for dto in dtos {
                        group.addTask {
                            let cleanUid = dto.fromUid.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !cleanUid.isEmpty else { return nil }
                            
                            do {
                                let profile = try await self.userService.fetchProfile(uid: cleanUid)
                                
                                let fullName = [profile.firstName, profile.lastName]
                                    .filter { !$0.isEmpty }
                                    .joined(separator: " ")
                                
                                let finalName = fullName.isEmpty ? profile.displayName : fullName
                                let finalHandle = "@\(profile.displayName)"
                                
                                let request = FriendRequest(
                                    fromUid: cleanUid,
                                    fromName: finalName.isEmpty ? "Unknown" : finalName,
                                    handle: finalHandle.isEmpty ? "@unknown" : finalHandle
                                )
                                
                                // NOTIFICATION LOGIC: Check if this request is new to the ViewModel
                                if !existingRequestUids.contains(cleanUid) {
                                    await MainActor.run {
                                        newRequestProfiles.append(request)
                                    }
                                }
                                
                                return request
                            } catch {
                                // Fallback to DTO data if fetch fails
                                print("Failed to hydrate request for \(cleanUid): \(error.localizedDescription)")
                                return FriendRequest(
                                    fromUid: cleanUid,
                                    fromName: dto.fromDisplay.isEmpty ? dto.fromHandle : dto.fromDisplay,
                                    handle: dto.fromHandle
                                )
                            }
                        }
                    }
                    
                    // Collect results
                    for await req in group {
                        if let req = req {
                            hydratedRequests.append(req)
                        }
                    }
                }
                
                // 3. Update UI
                self.requests = hydratedRequests.sorted { $0.fromName.localizedCaseInsensitiveCompare($1.fromName) == .orderedAscending }
                
                // 4. Trigger notifications for newly detected requests
                for newReq in newRequestProfiles {
                    self.notificationManager.scheduleFriendRequestNotification(
                        from: newReq.fromName,
                        handle: newReq.handle
                    )
                }

                // Clear any lingering error since a new successful snapshot arrived
                self.addError = nil
            }
        }
    }
    
    func remove(friendProfile: UserProfile) {
        guard let me = AuthService.shared.user?.id else { return }
        Task { @MainActor in
            do {
                try await requestService.removeFriend(me: me, other: friendProfile.uid)
                if let idx = friends.firstIndex(of: friendProfile) {
                    friends.remove(at: idx)
                } else {
                    friends.removeAll { $0.uid == friendProfile.uid }
                }
                friendIds.remove(friendProfile.uid)
                if !addQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    performAddSearch()
                }
                refreshFriends()
            } catch {
                print("Failed to remove friend: \(error)")
            }
        }
    }
    
    // Open profile from local object
    func openProfile(for profile: UserProfile) {
        self.selectedProfile = profile
        self.showingProfile = true
    }
    
    func openProfile(for searchResult: FriendSearchResult) {
        Task {
            await MainActor.run {
                selectedProfile = nil
                showingProfile = true
            }
            do {
                let profile = try await userService.fetchProfile(uid: searchResult.uid)
                await MainActor.run {
                    self.selectedProfile = profile
                }
            } catch {
                print("Failed to fetch profile: \(error)")
                await MainActor.run {
                    showingProfile = false
                }
            }
        }
    }
    
    func openProfile(for request: FriendRequest) {
        Task {
            await MainActor.run {
                selectedProfile = nil
                showingProfile = true
            }
            do {
                let profile = try await userService.fetchProfile(uid: request.fromUid)
                await MainActor.run {
                    self.selectedProfile = profile
                }
            } catch {
                print("Failed to fetch profile: \(error)")
                await MainActor.run {
                    showingProfile = false
                }
            }
        }
    }
    
    func isRequestPending(uid: String) -> Bool {
        pendingOutgoing.contains(uid)
    }
    func resetSessionData() {
        friends = []
        currentUser = nil
        requests = []
        sent = []
        pendingOutgoing = []
        addResults = []
        addQuery = ""
        requestService.stopListeningForIncoming()
    }
}
