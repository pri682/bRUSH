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
}
