import SwiftUI

struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel()
    @State private var showAddSheet = false
    @State private var showLeaderboard = false
    @State private var showRemoveConfirm = false
    @State private var pendingRemoval: Friend? = nil
    
    var body: some View {
        NavigationStack {
            List {
                if !vm.requests.isEmpty && vm.searchText.isEmpty {
                    Section("Friend Requests") {
                        ForEach(vm.requests) { req in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(req.fromName).font(.headline)
                                    Text(req.handle).foregroundStyle(.secondary).font(.caption)
                                }
                                Spacer()
                                Button("Accept") { vm.accept(req) }
                                    .buttonStyle(.glassProminent)
                                Button("Decline") { vm.decline(req) }
                                    .buttonStyle(.glass)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                Section("Friends (\(vm.filteredFriends.count))") {
                    ForEach(vm.filteredFriends) { friend in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(friend.name).font(.headline)
                            Text(friend.handle).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                        .onTapGesture { vm.openProfile(for: friend) }
                    }
                    .onDelete { indexSet in
                        let uids = indexSet.compactMap { idx in
                            vm.filteredFriends[safe: idx]?.uid
                        }
                        vm.removeLocally(uids: uids)
                        Task { await vm.removeRemote(uids: uids) }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.large)
            .onAppear { vm.loadMyProfileData(); vm.refreshFriends(); vm.refreshIncoming(); vm.loadLeaderboard(); vm.resetSessionData() }
            .searchable(text: $vm.searchText, prompt: "Search friends")
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation { showLeaderboard.toggle() }
                    } label: {
                        Image(systemName: "trophy")
                    }
                    .accessibilityLabel("Toggle Leaderboard")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.addQuery = ""
                        vm.addResults = []
                        vm.addError = nil
                        vm.isSearchingAdd = false
                        showAddSheet = true
                    } label: {
                        Label("Add Friend", systemImage: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddFriendView(vm: vm)
            }
            .sheet(isPresented: $vm.showingProfile) {
                if let p = vm.selectedProfile {
                    FriendProfileSheet(
                        profile: p,
                        onConfirmRemove: { uid in
                            if let f = vm.friends.first(where: { $0.uid == uid}) {
                                vm.remove(friend: f)
                            }
                        }
                    )
                } else {
                    // Fallback while loading
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading profile…")
                    }
                    .padding()
                    .presentationDetents([.fraction(0.3)])
                }
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardSheet(vm: vm)
            }
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
