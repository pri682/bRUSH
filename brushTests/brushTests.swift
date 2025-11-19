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

// MARK: - Leaderboard Tests
final class LeaderboardTests: XCTestCase {
    
    // Helper to create leaderboard entries
    private func makeEntry(
        uid: String,
        name: String = "Test User",
        handle: String = "@test",
        gold: Int,
        silver: Int,
        bronze: Int,
        submittedAt: Date = Date()
    ) -> LeaderboardEntry {
        LeaderboardEntry(
            uid: uid,
            fullName: name,
            handle: handle,
            gold: gold,
            silver: silver,
            bronze: bronze,
            submittedAt: submittedAt,
            profileImageURL: nil,
            avatarType: nil,
            avatarBackground: nil,
            avatarBody: nil,
            avatarShirt: nil,
            avatarEyes: nil,
            avatarMouth: nil,
            avatarHair: nil,
            avatarFacialHair: nil
        )
    }
    
    // Test: Points calculation formula
    func testPointsCalculation_CorrectFormula() {
        let entry = makeEntry(uid: "u1", gold: 3, silver: 5, bronze: 7)
        // 3*100 + 5*25 + 7*10 = 300 + 125 + 70 = 495
        XCTAssertEqual(entry.points, 495, "Points should be gold*100 + silver*25 + bronze*10")
    }
    
    func testPointsCalculation_ZeroMedals() {
        let entry = makeEntry(uid: "u1", gold: 0, silver: 0, bronze: 0)
        XCTAssertEqual(entry.points, 0, "Zero medals should result in zero points")
    }
    
    func testPointsCalculation_OnlyGold() {
        let entry = makeEntry(uid: "u1", gold: 2, silver: 0, bronze: 0)
        XCTAssertEqual(entry.points, 200, "Only gold medals: 2*100 = 200")
    }

// Test: Sorting by points (higher points first)
    func testSorting_HigherPointsFirst() {
        let low = makeEntry(uid: "low", gold: 1, silver: 0, bronze: 0)    // 100 pts
        let high = makeEntry(uid: "high", gold: 5, silver: 0, bronze: 0)  // 500 pts
        let mid = makeEntry(uid: "mid", gold: 3, silver: 0, bronze: 0)    // 300 pts
        
        var entries = [low, high, mid]
        entries.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.submittedAt < $1.submittedAt
        }
        
        XCTAssertEqual(entries.map { $0.uid }, ["high", "mid", "low"],
                      "Entries should be sorted by points descending")
    }
   
    // Test: Tie-breaking by submittedAt (earlier date wins)
    func testSorting_TieBreakByEarlierDate() {
        let baseDate = Date(timeIntervalSince1970: 1700000000)
        let earlier = makeEntry(uid: "earlier", gold: 2, silver: 0, bronze: 0, submittedAt: baseDate)
        let later = makeEntry(uid: "later", gold: 2, silver: 0, bronze: 0, submittedAt: baseDate.addingTimeInterval(60))
        
        var entries = [later, earlier]
        entries.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.submittedAt < $1.submittedAt
        }
        
        XCTAssertEqual(entries.map { $0.uid }, ["earlier", "later"],
                      "When points are equal, earlier submittedAt should rank higher")
    }