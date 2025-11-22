import SwiftUI

struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel()
    @State private var showAddSheet = false
    @State private var showLeaderboard = false
    @State private var isInitiallyLoading = true
    
    enum FriendsTab: String, CaseIterable {
        case friends = "Friends"
        case requests = "Requests"
    }
    @State private var selectedTab: FriendsTab = .friends
    
    var filteredRequests: [FriendRequest] {
        guard !vm.searchText.isEmpty else { return vm.requests }
        return vm.requests.filter {
            $0.fromName.lowercased().contains(vm.searchText.lowercased()) ||
            $0.handle.lowercased().contains(vm.searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header section with background
                VStack(spacing: 12) {
                    Picker("View", selection: $selectedTab) {
                        ForEach(FriendsTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(
                    Color.accentColor.opacity(0.15)
                        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                )

                List {
                    if selectedTab == .friends {
                        if vm.filteredFriends.isEmpty && !isInitiallyLoading {
                            if vm.searchText.isEmpty {
                                Text("No friends yet. Add some!")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("No friends found for \"\(vm.searchText)\"")
                                    .foregroundStyle(.secondary)
                            }
                        } else if isInitiallyLoading && vm.friends.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                        
                        ForEach(vm.filteredFriends, id: \.uid) { profile in
                            friendRow(profile)
                        }
                        .onDelete(perform: deleteFriends)
                        
                    } else if selectedTab == .requests {
                        if filteredRequests.isEmpty && !isInitiallyLoading {
                            if vm.searchText.isEmpty {
                                Text("No new friend requests.")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("No requests found for \"\(vm.searchText)\"")
                                    .foregroundStyle(.secondary)
                            }
                        } else if isInitiallyLoading && vm.requests.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                        
                        ForEach(filteredRequests) { req in
                            requestRow(req)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(
                    Color.accentColor.opacity(0.15)
                        .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
                )
            }
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                guard isInitiallyLoading else { return }
                
                vm.loadMyProfileData()
                vm.refreshFriends()
                vm.refreshIncoming()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isInitiallyLoading = false
                }
            }
            .navigationTitle("Friends")
            .searchable(text: $vm.searchText, prompt: "Search \(selectedTab.rawValue)")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.loadLeaderboard() // Ensure fresh sort based on current data
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
            .sheet(isPresented: Binding(
                get: { vm.showingProfile && !showLeaderboard },
                set: { vm.showingProfile = $0 }
            )) {
                if let p = vm.selectedProfile {
                    FriendProfileSheet(vm: vm, profile: p)
                } else {
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
    
    @ViewBuilder
    private func friendRow(_ profile: UserProfile) -> some View {
        HStack(spacing: 12) {
            AvatarView(
                avatarType: AvatarType(rawValue: profile.avatarType) ?? .personal,
                background: profile.avatarBackground ?? "background_1",
                avatarBody: profile.avatarBody,
                shirt: profile.avatarShirt,
                eyes: profile.avatarEyes,
                mouth: profile.avatarMouth,
                hair: profile.avatarHair,
                facialHair: profile.avatarFacialHair,
                includeSpacer: false
            )
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 2) {
                let name = [profile.firstName, profile.lastName].filter { !$0.isEmpty }.joined(separator: " ")
                Text(name.isEmpty ? profile.displayName : name)
                    .font(.headline)
                Text("@\(profile.displayName)")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture { vm.openProfile(for: profile) }
    }
    
    @ViewBuilder
    private func requestRow(_ req: FriendRequest) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(req.fromName).font(.headline)
                Text(req.handle).foregroundStyle(.secondary).font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                vm.openProfile(for: req)
            }
            
            Spacer()
            
            if vm.searchText.isEmpty {
                Button("Accept") { vm.accept(req) }
                    .buttonStyle(.glassProminent)
                Button("Decline") { vm.decline(req) }
                    .buttonStyle(.glass)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func deleteFriends(at offsets: IndexSet) {
        let profilesToDelete = offsets.compactMap { idx in
            vm.filteredFriends[safe: idx]
        }
        let uids = profilesToDelete.map { $0.uid }
        vm.removeLocally(uids: uids)
        Task { await vm.removeRemote(uids: uids) }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
