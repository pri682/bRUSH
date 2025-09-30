import SwiftUI

struct FriendsView: View {
    @StateObject private var vm = FriendsViewModel()
    
    var body: some View {
        List(vm.filteredFriends) { friend in
            VStack(alignment: .leading) {
                Text(friend.name).font(.headline)
                Text(friend.handle).foregroundColor(.secondary)
            }
        }
        .navigationTitle("Friends")
        .onAppear { vm.loadMock() }
        .searchable(text: $vm.searchText, prompt: "Search friends")
    }
}
