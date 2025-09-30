import Foundation
import SwiftUI
import Combine

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var searchText: String = ""
    @Published var requests: [FriendRequest] = [
        FriendRequest(fromName: "Marcus", handle: "@m.aurelius"),
        FriendRequest(fromName: "Taylor",   handle: "@tswift22")
    ]
    
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
    func accept(_ req: FriendRequest) {
        friends.append(Friend(name: req.fromName, handle: req.handle))
        requests.removeAll { $0.id == req.id }
    }
    func decline(_ req: FriendRequest) {
        requests.removeAll { $0.id == req.id }
    }
}

