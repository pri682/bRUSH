import Foundation
import SwiftUI
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var searchText: String = ""
    
    func loadMock() {
        friends = [
            Friend(name: "Ted", handle: "@grumpyoldman"),
            Friend(name: "Aaron", handle: "@lunchalone"),
            Friend(name: "Jeffrey", handle: "@dahmer")
        ]
    }
    var filteredFriends: [Friend] {
        guard !searchText.isEmpty else { return friends }
        return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) ||
                                $0.handle.lowercased().contains(searchText.lowercased()) }
    }
}

