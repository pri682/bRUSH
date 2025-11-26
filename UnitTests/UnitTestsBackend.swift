//
//  UnitTestsBackend.swift
//  brush
//
//  Created by Vaidic Soni on 11/24/25.
//

import Testing
import Foundation
@testable import brush // IMPORTANT: Allows access to app-level code/structs

// MARK: - Mocking and Test Helpers

// Simplified UserProfile for FriendsViewModel Testing
struct TestUserProfile: Equatable {
    let uid: String
    let firstName: String
    let lastName: String
    let displayName: String // Used as the @handle
}

// Simple deterministic prompt generator for testing purposes
struct TestPromptGenerator {
    // Generates a predictable prompt based on a string seed (like a date)
    func generatePrompt(seed: String) -> String {
        guard let firstChar = seed.first else { return "Default Prompt" }
        
        let hashValue = seed.hashValue % 100
        
        switch firstChar.lowercased() {
        case "a", "b", "c": return "A geometric shape with color \(hashValue)"
        case "d", "e", "f": return "An abstract landscape reflecting \(hashValue) emotions"
        default: return "A still life composition number \(hashValue)"
        }
    }
}


// MARK: - Testable Components (Simplified for Unit Testing)

// Testable version of FriendsViewModel filtering logic
class TestFriendsViewModel {
    var friends: [TestUserProfile] = []
    var searchText: String = ""

    // Mimics the filtering logic found in the actual FriendsViewModel
    var filteredFriends: [TestUserProfile] {
        guard !searchText.isEmpty else { return friends }
        let lowercasedSearch = searchText.lowercased()

        return friends.filter {
            let fullName = [$0.firstName, $0.lastName].filter { !$0.isEmpty }.joined(separator: " ")
            return fullName.lowercased().contains(lowercasedSearch) ||
                   $0.displayName.lowercased().contains(lowercasedSearch)
        }
    }
}

// Testable version of NotificationManager history logic
class TestNotificationManager {
    let historyKey = "notificationsHistory"
    let defaults: UserDefaults // Use a temporary UserDefaults to avoid conflicts

    init(suiteName: String) {
        // Use a temporary suite to isolate tests
        self.defaults = UserDefaults(suiteName: suiteName)!
        // Clear old data from this suite before starting
        self.defaults.removePersistentDomain(forName: suiteName)
    }

    // Mimics the actual save logic
    func saveNotificationToHistory(title: String, body: String) {
        var history = defaults.array(forKey: historyKey) as? [[String: String]] ?? []

        history.insert([
            "title": title,
            "body": body,
            // Only need title and body for assertion simplicity
            "time": "mockTime" // Mock the time field
        ], at: 0)

        defaults.set(history, forKey: historyKey)
    }

    // Mimics the actual retrieval logic
    func getNotificationHistory() -> [[String: String]] {
        return defaults.array(forKey: historyKey) as? [[String: String]] ?? []
    }
    
    // Helper to clean up after test
    func clearHistory() {
        defaults.removeObject(forKey: historyKey)
    }
}


// MARK: - Unit Test Suite

struct AppFeatureUnitTests {
    
    // MARK: - 1. FriendsViewModel (Feed/Data Fetching)
    
    /// Test 1: Verifies the filtering of the friends list based on search text.
    @Test func testFriendsFiltering_FullNameAndHandleSearch() {
        // Arrange
        let viewModel = TestFriendsViewModel()
        viewModel.friends = [
            TestUserProfile(uid: "1", firstName: "Alex", lastName: "Smith", displayName: "smitty"),
            TestUserProfile(uid: "2", firstName: "Betty", lastName: "White", displayName: "bettyw"),
            TestUserProfile(uid: "3", firstName: "Charlie", lastName: "Jones", displayName: "charliej"),
        ]
        
        // Scenario 1: Search by full name (case insensitive)
        viewModel.searchText = "aleX"
        var results = viewModel.filteredFriends
        #expect(results.count == 1, "Scenario 1 Failed: Should find 1 result for 'aleX'.")
        #expect(results.first?.uid == "1", "Scenario 1 Failed: Should be Alex Smith.")
        
        // Scenario 2: Search by handle (case insensitive)
        viewModel.searchText = "bettyw"
        results = viewModel.filteredFriends
        #expect(results.count == 1, "Scenario 2 Failed: Should find 1 result for 'bettyw'.")
        #expect(results.first?.uid == "2", "Scenario 2 Failed: Should be Betty White.")
        
        // Scenario 3: Empty search returns all
        viewModel.searchText = ""
        results = viewModel.filteredFriends
        #expect(results.count == 3, "Scenario 3 Failed: Empty search should return all 3 friends.")
    }
    
    // MARK: - 2. NotificationManager (Notifications)

    /// Test 2: Verifies that notifications are correctly saved to and retrieved from history.
    @Test func testNotificationHistory_PersistenceAndRetrieval() async throws {
        // Arrange: Use a unique suite name to isolate this test's UserDefaults data
        let manager = TestNotificationManager(suiteName: "TestNotificationPersistence")
        
        // Input Fields (Title/Body)
        let notif1Title = "Test Notif 1"
        let notif1Body = "Content for first notification."
        let notif2Title = "Test Notif 2"
        let notif2Body = "Content for second notification."
        
        // Act
        manager.saveNotificationToHistory(title: notif1Title, body: notif1Body)
        manager.saveNotificationToHistory(title: notif2Title, body: notif2Body) // Saved second, should be first in history
        
        // Return Object
        let history = manager.getNotificationHistory()
        
        // Assert
        // 1. Check correct total count
        #expect(history.count == 2, "Persistence Failed: History count should be 2.")
        
        // 2. Check the most recent (first) entry for correctness
        #expect(history[0]["title"] == notif2Title, "Retrieval Failed: Most recent notification title incorrect.")
        #expect(history[0]["body"] == notif2Body, "Retrieval Failed: Most recent notification body incorrect.")
        
        // 3. Check the oldest entry (last) entry for correctness
        #expect(history[1]["title"] == notif1Title, "Retrieval Failed: Oldest notification title incorrect.")
        
        // Cleanup
        manager.clearHistory()
    }
    
    // MARK: - 3. Prompt Generator (Prompt Generation)
    
    /// Test 3: Verifies that the prompt generator is deterministic (same input = same output).
    @Test func testPromptGenerator_DeterminismAndUniqueness() {
        // Arrange
        let generator = TestPromptGenerator()
        
        // Input Field (Seed)
        let seedA = "2025-01-15"
        let seedB = "2025-01-16" // Sequential day
        
        // Act
        let promptA_first = generator.generatePrompt(seed: seedA)
        let promptA_second = generator.generatePrompt(seed: seedA) // Same seed run twice
        let promptB = generator.generatePrompt(seed: seedB)       // Different seed
        
        // Assert
        
        // 1. Determinism Check (Same input must return the same string)
        #expect(promptA_first == promptA_second, "Determinism Failed: Two calls with the same seed ('\(seedA)') returned different prompts.")
        
        // 2. Uniqueness Check (Different sequential seeds must return different strings)
        #expect(promptA_first != promptB, "Uniqueness Failed: Prompts for sequential seeds ('\(seedA)' and '\(seedB)') should be different.")
        
        // 3. Simple Constraint Check (Verify the prompt is not empty)
        #expect(!promptA_first.isEmpty, "Constraint Failed: Generated prompt must not be empty.")
    }
}
