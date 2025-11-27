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

