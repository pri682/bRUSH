import SwiftUI

struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel()
    @State private var showAddSheet = false
    
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
                    showAddSheet = true
                    } label: {
                    Label("Add Friend", systemImage: "person.badge.plus")
                    }
                    .accessibilityLabel("Add Friend")
                }
            }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                Text("Add Friend")
                    .navigationTitle("Add Friend")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showAddSheet = false }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear { vm.loadMock() }
        .searchable(text: $vm.searchText, prompt: "Search friends")
    }
}
