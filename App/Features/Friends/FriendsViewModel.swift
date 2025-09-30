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
    @Published var addQuery: String = ""
    @Published var addResults: [FriendSearchResult] = []
    @Published var isSearchingAdd: Bool = false
    @Published var addError: String?
    
    private let _mockDirectory: [FriendSearchResult] = [
        .init(handle: "jesse",  displayName: "Jesse Flynn"),
        .init(handle: "kelvin",  displayName: "Kelvin Mathew"),
        .init(handle: "priyanka", displayName: "Priyanka Karki"),
        .init(handle: "vaidic",  displayName: "Vaidic Soni"),
        .init(handle: "meidad",  displayName: "Meidad Troper")
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
    func performAddSearch() {
        let raw = addQuery
            .replacingOccurrences(of: "@", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !raw.isEmpty else {
            addResults = []
            return
        }
        isSearchingAdd = true
        addError = nil

        addResults = _mockDirectory
            .filter { $0.handle.contains(raw) }
            .sorted { $0.handle < $1.handle }

        isSearchingAdd = false
    }
    func sendFriendRequest(to user: FriendSearchResult) {
        requests.append(FriendRequest(fromName: user.displayName, handle: "@\(user.handle)"))
    }
}

