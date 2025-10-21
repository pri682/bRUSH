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
                if showLeaderboard {
                    Section {
                        if vm.isLoadingLeaderboard {
                            HStack {
                                ProgressView()
                                Text("Loading leaderboard…")
                            }
                        } else if let err = vm.leaderboardError {
                            Text(err).foregroundStyle(.red)
                        } else if vm.leaderboard.isEmpty {
                            Text("No friend rankings yet for today.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(vm.leaderboard.enumerated()), id: \.1.id) { index, entry in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.system(.body, design: .monospaced))
                                        .bold()
                                        .frame(width: 30, alignment: .trailing)
                                    
                                    VStack(alignment: .leading) {
                                        Text(entry.displayName).font(.body.weight(.semibold))
                                        Text(entry.handle).font(.caption).foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(entry.points) pts")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 6)
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
                        VStack(alignment: .leading) {
                            Text(friend.name).font(.headline)
                            Text(friend.handle).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture { vm.openProfile(for: friend) }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                pendingRemoval = friend
                                showRemoveConfirm = true
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .onAppear {
                vm.loadMyHandle()
                vm.refreshFriends()
                vm.refreshIncoming()
                vm.loadLeaderboard() }
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
            .confirmationDialog(
                pendingRemoval.map { "Remove \($0.name) as a friend?" } ?? "Remove friend?",
                isPresented: $showRemoveConfirm,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    if let f = pendingRemoval { vm.remove(friend: f) }
                    pendingRemoval = nil
                }
                Button("Cancel", role: .cancel) {
                    pendingRemoval = nil
                }
            }
            .sheet(isPresented: $vm.showingProfile) {
                if let p = vm.selectedProfile {
                    FriendProfileSheet(
                        profile: p,
                        onRemoveTapped: {
                            // close sheet, then reuse existing confirm flow
                            pendingRemoval = Friend(uid: p.uid, name: p.displayName, handle: "@\(p.displayName)")
                            vm.showingProfile = false
                            showRemoveConfirm = true
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
        }
    }
}
        private struct FriendProfileSheet: View {
            let profile: UserProfile
            var onRemoveTapped: () -> Void = {}

            @Environment(\.dismiss) private var dismiss

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
                            onRemoveTapped()
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
            }

            // tiny helper
            private func Stat(_ label: String, _ value: Int) -> some View {
                VStack {
                    Text("\(value)").bold()
                    Text(label).font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }

