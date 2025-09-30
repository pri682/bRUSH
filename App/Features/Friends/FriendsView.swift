import SwiftUI

struct FriendsView: View {
    let mockFriends = [
        Friend(name: "Ted", handle: "@grumpyoldman"),
        Friend(name: "Aaron", handle: "@lunchalone"),
        Friend(name: "Jeffrey", handle: "@dahmer")
    ]
    
    var body: some View {
        List(mockFriends) { friend in
            VStack(alignment: .leading) {
                Text(friend.name).font(.headline)
                Text(friend.handle).foregroundColor(.secondary)
            }
        }
        .navigationTitle("Friends")
    }
}
