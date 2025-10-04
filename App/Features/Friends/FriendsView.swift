import SwiftUI

struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel()
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
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
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Friends")
            .toolbar {
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
                    .accessibilityLabel("Add Friend")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddFriendView(vm: vm)
            }
        }
        .onAppear { vm.loadMock(); vm.loadLeaderboard() }
        .searchable(text: $vm.searchText, prompt: "Search friends")
    }
}
