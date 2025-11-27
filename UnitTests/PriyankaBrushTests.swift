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

 
    // Test: User with high score appears at top
    func testLeaderboard_HighScoreAtTop() {
        let user1 = makeEntry(uid: "u1", name: "Alice", gold: 1, silver: 2, bronze: 3)  // 155 pts
        let user2 = makeEntry(uid: "u2", name: "Bob", gold: 5, silver: 1, bronze: 0)    // 525 pts
        let user3 = makeEntry(uid: "u3", name: "Carol", gold: 2, silver: 0, bronze: 5)  // 250 pts
        
        var leaderboard = [user1, user2, user3]
        leaderboard.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.submittedAt < $1.submittedAt
        }
        
        XCTAssertEqual(leaderboard[0].uid, "u2", "Bob with 525 pts should be rank 1")
        XCTAssertEqual(leaderboard[1].uid, "u3", "Carol with 250 pts should be rank 2")
        XCTAssertEqual(leaderboard[2].uid, "u1", "Alice with 155 pts should be rank 3")
    }

// Test: Multiple users with same score, sorted by submission time
    func testLeaderboard_SameScoreSortedByTime() {
        let baseDate = Date(timeIntervalSince1970: 1700000000)
        let user1 = makeEntry(uid: "u1", name: "First", gold: 3, silver: 0, bronze: 0, submittedAt: baseDate)
        let user2 = makeEntry(uid: "u2", name: "Second", gold: 3, silver: 0, bronze: 0, submittedAt: baseDate.addingTimeInterval(10))
        let user3 = makeEntry(uid: "u3", name: "Third", gold: 3, silver: 0, bronze: 0, submittedAt: baseDate.addingTimeInterval(20))
        
        var leaderboard = [user3, user1, user2]
        leaderboard.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.submittedAt < $1.submittedAt
        }
        
        XCTAssertEqual(leaderboard.map { $0.uid }, ["u1", "u2", "u3"],
                      "Same points should be ordered by earliest submission time")
    }
}


    
//
//  PriyankaBrushTests.swift
//  UnitTests
//
//  Created by Priyanka Karki on 11/26/25.
//

import XCTest
@testable import brush

// MARK: - Leaderboard Tests
final class LeaderboardTests: XCTestCase {

    // Helper to build a UserProfile with specified medals
    private func makeProfile(uid: String, name: String, gold: Int, silver: Int, bronze: Int) -> UserProfile {
        return UserProfile(
            uid: uid,
            firstName: name,
            lastName: "",
            displayName: name.lowercased(),
            email: "\(name.lowercased())@example.com",
            avatarType: "personal",
            avatarBackground: nil,
            avatarBody: nil,
            avatarFace: nil,
            avatarShirt: nil,
            avatarEyes: nil,
            avatarMouth: nil,
            avatarHair: nil,
            avatarFacialHair: nil,
            goldMedalsAccumulated: gold,
            silverMedalsAccumulated: silver,
            bronzeMedalsAccumulated: bronze,
            goldMedalsAwarded: 0,
            silverMedalsAwarded: 0,
            bronzeMedalsAwarded: 0,
            totalDrawingCount: 0,
            streakCount: 0,
            memberSince: Date(),
            lastCompletedDate: nil,
            lastAttemptedDate: nil
        )
    }

    // Wraps the profile helper to create a LeaderboardEntry
    private func makeEntry(uid: String, name: String, gold: Int, silver: Int, bronze: Int) -> LeaderboardEntry {
        LeaderboardEntry(profile: makeProfile(uid: uid, name: name, gold: gold, silver: silver, bronze: bronze))
    }

    // Verify points formula: gold×100 + silver×25 + bronze×10
    func testPointsCalculation() {
        let e = makeEntry(uid: "u1", name: "Alice", gold: 3, silver: 5, bronze: 7)
        XCTAssertEqual(e.points, 495)
        let zero = makeEntry(uid: "u2", name: "Bob", gold: 0, silver: 0, bronze: 0)
        XCTAssertEqual(zero.points, 0)
        let goldOnly = makeEntry(uid: "u3", name: "Carol", gold: 2, silver: 0, bronze: 0)
        XCTAssertEqual(goldOnly.points, 200)
    }

    // Higher points should rank first
    func testSorting_HigherPointsFirst() {
        let low = makeEntry(uid: "low", name: "Low", gold: 1, silver: 0, bronze: 0)    // 100
        let high = makeEntry(uid: "high", name: "High", gold: 5, silver: 0, bronze: 0) // 500
        let mid = makeEntry(uid: "mid", name: "Mid", gold: 3, silver: 0, bronze: 0)    // 300

        var entries: [LeaderboardEntry] = [low, high, mid]
        entries.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.fullName.lowercased() < $1.fullName.lowercased()
        }

        XCTAssertEqual(entries.map { $0.uid }, ["high", "mid", "low"])
    }

    // Equal points should be sorted alphabetically by name
    func testSorting_TieBreakByNameWhenPointsEqual() {
        let a = makeEntry(uid: "a", name: "Alpha", gold: 2, silver: 0, bronze: 0) // 200
        let b = makeEntry(uid: "b", name: "Beta",  gold: 2, silver: 0, bronze: 0) // 200

        var entries: [LeaderboardEntry] = [b, a]
        entries.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.fullName.lowercased() < $1.fullName.lowercased()
        }

        XCTAssertEqual(entries.map { $0.uid }, ["a", "b"]) // Alpha before Beta
    }

    // When total points are equal, more gold medals wins
    func testWinnerWithMoreGoldButFewerBronze() {
        let user1 = makeEntry(uid: "u1", name: "Goldie", gold: 4, silver: 0, bronze: 0) // 400
        let user2 = makeEntry(uid: "u2", name: "Bronzo", gold: 3, silver: 0, bronze: 10) // 300 + 100 = 400

        var entries: [LeaderboardEntry] = [user2, user1]
        entries.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            // If equal points, prefer more gold, then silver, then bronze
            if $0.gold != $1.gold { return $0.gold > $1.gold }
            if $0.silver != $1.silver { return $0.silver > $1.silver }
            if $0.bronze != $1.bronze { return $0.bronze > $1.bronze }
            return $0.fullName.lowercased() < $1.fullName.lowercased()
        }

        XCTAssertEqual(entries.first?.uid, "u1")
    }

    // Multiple users with same score appear in alphabetical order
    func testManyUsersSameScore_OrderDeterministic() {
        let users: [LeaderboardEntry] = [
            makeEntry(uid: "u1", name: "Ann",   gold: 2, silver: 0, bronze: 0),
            makeEntry(uid: "u2", name: "Zoe",   gold: 2, silver: 0, bronze: 0),
            makeEntry(uid: "u3", name: "Mike",  gold: 2, silver: 0, bronze: 0),
            makeEntry(uid: "u4", name: "Beth",  gold: 2, silver: 0, bronze: 0),
            makeEntry(uid: "u5", name: "Carl",  gold: 2, silver: 0, bronze: 0)
        ]

        var leaderboard = users
        leaderboard.sort {
            if $0.points != $1.points { return $0.points > $1.points }
            return $0.fullName.lowercased() < $1.fullName.lowercased()
        }

        // Deterministic alphabetical order for equal points
        XCTAssertEqual(leaderboard.map { $0.uid }, ["u1", "u4", "u5", "u3", "u2"]) // Ann, Beth, Carl, Mike, Zoe
        XCTAssertEqual(leaderboard.count, 5)
    }
}

