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
    
}
