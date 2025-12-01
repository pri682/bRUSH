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

                List {
                    if selectedTab == .friends {
                        // LOADING STATE
                        if isInitiallyLoading && vm.friends.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView("Loading friends...")
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 20)
                        }
                        else if vm.filteredFriends.isEmpty {
                            if vm.searchText.isEmpty {
                                ContentUnavailableView {
                                    Label("No friends yet", systemImage: "person.2.slash")
                                } description: {
                                    Text("Add some friends to start competing!")
                                }
                                .listRowBackground(Color.clear)
                            } else {
                                Text("No friends found for \"\(vm.searchText)\"")
                                    .foregroundStyle(.secondary)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        else {
                            // Group users in a section to club them together with dividers
                            Section {
                                ForEach(vm.filteredFriends, id: \.uid) { profile in
                                    friendRow(profile)
                                }
                                .onDelete(perform: deleteFriends)
                            }
                        }
                        
                    } else if selectedTab == .requests {
                        if isInitiallyLoading && vm.requests.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        else if filteredRequests.isEmpty {
                            if vm.searchText.isEmpty {
                                ContentUnavailableView {
                                    Label("No requests", systemImage: "envelope.open")
                                } description: {
                                    Text("You're all caught up.")
                                }
                                .listRowBackground(Color.clear)
                            } else {
                                Text("No requests found for \"\(vm.searchText)\"")
                                    .foregroundStyle(.secondary)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        else {
                            Section {
                                ForEach(filteredRequests) { req in
                                    requestRow(req)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.visible)
                .refreshable {
                    await vm.refreshAllData()
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await vm.refreshAllData()
                    withAnimation {
                        isInitiallyLoading = false
                    }
                }
            }
            .navigationTitle("Friends")
            .searchable(text: $vm.searchText, prompt: "Search \(selectedTab.rawValue)")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.loadLeaderboard()
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
        .padding(.vertical, 6)
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
                Button("Accept") {
                    Task { await vm.accept(req) }
                }
                .buttonStyle(.glassProminent)
                
                Button("Decline") {
                    Task { await vm.decline(req) }
                }
                .buttonStyle(.glass)
            }
        }
        .padding(.vertical, 6)
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
