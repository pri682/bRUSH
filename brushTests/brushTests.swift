import XCTest
@testable import brush

final class FriendsViewModelTests: XCTestCase {

    @MainActor
    func testFilteredFriends_MatchesByNameOrHandle() {
        let vm = FriendsViewModel()
        vm.friends = [
            Friend(uid: "u1", name: "Alice", handle: "@alice"),
            Friend(uid: "u2", name: "Bob",   handle: "@bobby"),
            Friend(uid: "u3", name: "Cathy", handle: "@cat")
        ]

        vm.searchText = "bo"
        XCTAssertEqual(vm.filteredFriends.map(\.uid), ["u2"])

        vm.searchText = "@cat"
        XCTAssertEqual(vm.filteredFriends.map(\.uid), ["u3"])

        vm.searchText = ""
        XCTAssertEqual(vm.filteredFriends.count, 3)
    }
    
    @MainActor
    func testRemoveLocally_RemovesFriendsAndIds() {
        let vm = FriendsViewModel()
        vm.friends = [
            Friend(uid: "a", name: "A", handle: "@a"),
            Friend(uid: "b", name: "B", handle: "@b"),
            Friend(uid: "c", name: "C", handle: "@c"),
        ]
        vm.friendIds = ["a", "b", "c"]
        vm.addQuery = "" // so performAddSearch() won’t be called

        vm.removeLocally(uids: ["b", "c"])
        XCTAssertEqual(vm.friends.map(\.uid), ["a"])
        XCTAssertEqual(vm.friendIds, ["a"])
    }
    
    // Ensures we don’t append duplicate "Pending" rows when a request was already sent.
    @MainActor
    func testSendFriendRequest_SkipsWhenAlreadySent() {
        let vm = FriendsViewModel()

        // Pretend we already sent to uX once
        vm.sent = [SentFriendRequest(toName: "Zoe", toUid: "uX", handle: "@zoe")]

        // Try to send again to the same uid
        let target = FriendSearchResult(uid: "uX", handle: "zoe", displayName: "Zoe")
        vm.sendFriendRequest(to: target)

        // Because of the guard !sent.contains(where: { $0.toUid == user.uid })
        // count should remain 1 (no duplicate appended)
        XCTAssertEqual(vm.sent.count, 1)
        XCTAssertEqual(vm.sent.first?.toUid, "uX")
    }
}
