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
                if !vm.requests.isEmpty {
                    Section("Friend Requests") {
                        ForEach(vm.requests) { req in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(req.fromName).font(.headline)
                                    Text(req.handle).foregroundStyle(.secondary).font(.caption)
                                }
                                Spacer()
                                Button("Accept") { vm.accept(req) }
                                    .buttonStyle(.borderedProminent)
                                Button("Decline") { vm.decline(req) }
                                    .buttonStyle(.bordered)
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
                .listStyle(.insetGrouped)
                .listSectionSpacing(.compact)
            }
            .onAppear { vm.loadMyHandle(); vm.refreshFriends(); vm.refreshIncoming(); vm.loadLeaderboard(); vm.resetSessionData() }
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
    private struct LeaderboardBarRow: View {
        let rank: Int
        let name: String
        let handle: String
        let points: Int
        let maxPoints: Int
        var useColor: Bool
        
        @Environment(\.colorScheme) private var scheme
        
        var ratio: CGFloat {
            guard maxPoints > 0 else { return 0 }
            return CGFloat(points) / CGFloat(maxPoints)
        }
        
        // Simple color scheme: top 1–3 get distinct tints; others use accent/gray.
        var barColor: Color {
            if !useColor {
                return .accentColor   // neutral-but-on-brand
            } else {
                switch rank {
                case 1: return.yellow     // 🥇
                case 2: return.gray         // 🥈
                case 3: return.brown       // 🥉
                default: return.blue        // everyone else
                }
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                // Title line
                HStack(spacing: 8) {
                    Text("\(rank)")
                        .font(.system(.subheadline, design: .monospaced)).bold()
                        .frame(width: 22, alignment: .trailing)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name).font(.subheadline).bold()
                        Text(handle).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                }
                
                // Bar line
                GeometryReader { geo in
                    let fullW = geo.size.width
                    let barW = max(0, min(fullW, fullW * ratio))
                    
                    ZStack(alignment: .leading) {
                        // Track
                        Capsule()
                            .fill(scheme == .dark ? Color.white.opacity(0.10)
                                  : Color.black.opacity(0.08))
                        
                        // Fill
                        Capsule()
                            .fill(barColor)
                            .frame(width: barW)
                        
                        // Points label in bar, right aligned
                        HStack {
                            Spacer()
                            Text("\(points)")
                                .font(.caption).bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .foregroundStyle( // readable on both light/dark & colors
                                    useColor ? Color.black : (scheme == .dark ? .white : .black)
                                )
                                .padding(.trailing, 4)
                        }
                    }
                }
                .frame(height: 24)
            }
            .animation(.easeOut(duration: 0.22), value: points)
        }
    }
    private struct LeaderboardSheet: View {
        @ObservedObject var vm: FriendsViewModel
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationStack {
                List {
                    Section {
                        let maxPoints = vm.leaderboard.map(\.points).max() ?? 0
                        
                        if vm.isLoadingLeaderboard {
                            HStack {
                                ProgressView()
                                Text("Loading leaderboard…")
                            }
                        } else if let err = vm.leaderboardError {
                            Text(err).foregroundStyle(.red)
                        } else if vm.leaderboard.isEmpty {
                            Text("No friend rankings yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(vm.leaderboard.enumerated()), id: \.1.id) { index, entry in
                                LeaderboardBarRow(
                                    rank: index + 1,
                                    name: entry.displayName,
                                    handle: entry.handle,
                                    points: entry.points,
                                    maxPoints: maxPoints,
                                    useColor: false // change to true to use colored bars
                                )
                                .padding(.vertical, 2)
                            }
                        }
                    } header: {
                        HStack {
                            Text("Friends Leaderboard")
                            Spacer()
                            Button {
                                vm.loadLeaderboard()
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .listSectionSpacing(.compact)
                .navigationTitle("Leaderboard")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
                // refresh when sheet opens
                .onAppear { vm.loadLeaderboard() }
                // If friend list loads/changes while the sheet is open, refresh
                .onChange(of: vm.friendIds) { vm.loadLeaderboard() }
            }
            .presentationDetents([.medium, .large])
            .presentationBackground(Color(.systemBackground))
        }
    }
}
    private struct FriendProfileSheet: View {
        let profile: UserProfile
        var onConfirmRemove: (String) -> Void = { _ in }
        
        @Environment(\.dismiss) private var dismiss
        @State private var confirmRemove = false
        
        var body: some View {
            VStack(spacing: 16) {
                // Avatar stub (swap for avatar pieces later)
                Circle()
                    .frame(width: 72, height: 72)
                    .overlay(Text(profile.displayName.prefix(1)).font(.title))
                    .accessibilityHidden(true)
                
                VStack(spacing: 2) {
                    Text(profile.displayName)
                        .font(.title3).bold()
                    Text("@\(profile.displayName)")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                
                // Quick stats row
                HStack(spacing: 24) {
                    Stat("Gold", profile.goldMedalsAccumulated)
                    Stat("Silver", profile.silverMedalsAccumulated)
                    Stat("Bronze", profile.bronzeMedalsAccumulated)
                }
                
                // Actions
                HStack(spacing: 12) {
                    Button("Close") { dismiss() }
                        .buttonStyle(.bordered)
                    
                    Button(role: .destructive) {
                        confirmRemove = true
                    } label: {
                        Label("Remove Friend", systemImage: "person.fill.xmark")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 4)
            }
            .padding()
            .presentationDetents([.medium, .large])
            .presentationBackground(Color(.systemBackground)) // opaque profile sheet
            
            .confirmationDialog(
                "Remove \(profile.displayName) as a friend?",
                isPresented: $confirmRemove,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    onConfirmRemove(profile.uid)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    // tiny helper
    private func Stat(_ label: String, _ value: Int) -> some View {
        VStack {
            Text("\(value)").bold()
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    private extension Array {
        subscript(safe index: Index) -> Element? {
            indices.contains(index) ? self[index] : nil
        }
    }

