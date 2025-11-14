//
//  UnitTests.swift
//  UnitTests
//
//  Created by Meidad Troper on 11/13/25.
//

import Testing
import Foundation
@testable import brush // IMPORTANT: Allows access to app-level code


// 1. Essential contract for our authentication dependency
protocol AuthProtocol {
    var isSignedIn: Bool { get }
}

// 2. Mock implementation to control the state for testing
class MockAuthService: AuthProtocol {
    var isSignedIn: Bool
    
    init(isSignedIn: Bool) {
        self.isSignedIn = isSignedIn
    }
    
    
}

// 3. The testable component (ViewModel)
class TestProfileViewModel {
    private var authService: AuthProtocol
    
    // Simulating user input state
        var username: String = ""

    init(authService: AuthProtocol) {
        self.authService = authService
    }

    // Function to be tested: checks the current sign-in status
    func checkSignInStatus() -> Bool {
        return authService.isSignedIn
    }
    
    // Function 2: simple validation logic (must be >= 3 chars after trimming)
        var isUsernameValid: Bool {
            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmedUsername.isEmpty && trimmedUsername.count >= 3
        }
}

struct UnitTests {
    
    /// Test 1: Verifies the ViewModel correctly handles the 'signed-in' state.
    @Test func testCheckSignInStatus_WhenSignedIn() {
        let mockAuthService = MockAuthService(isSignedIn: true) // check if isSignedIn is true
        let viewModel = TestProfileViewModel(authService: mockAuthService)
        // Expect true, show error message otherwise:
        #expect(viewModel.checkSignInStatus() == true, "Signed In Check Failed: Should return true when the service is signed in.")
    }
    
    /// Test 2: Verifies the ViewModel correctly handles the 'signed-out' state and updates.
    @Test func testCheckSignInStatus_WhenSignedOut() {
        
        // check status after signout:
        let mockAuthService = MockAuthService(isSignedIn: false)
        
        let viewModel = TestProfileViewModel(authService: mockAuthService)
        
        // We expect the ViewModel to simply return the 'false' state it received after a sign out:
        #expect(viewModel.checkSignInStatus() == false, "Signed Out Check Failed: Should return false when the service is signed out.")
    }
    
    // test 3: Verifies that the ViewModel correctly validates username length
    @Test func testUsernameValidation_LengthCheck() {
        // Arrange
        let mockAuthService = MockAuthService(isSignedIn: true)
        let viewModel = TestProfileViewModel(authService: mockAuthService)
        
        // Scenario 1: Too short (2 characters)
        viewModel.username = "jo"
        #expect(viewModel.isUsernameValid == false, "Validation Failed: 'jo' should be invalid (too short).")
        
        // Scenario 2: Valid length (4 characters)
        viewModel.username = "jojo"
        #expect(viewModel.isUsernameValid == true, "Validation Failed: 'jojo' should be valid.")
        
    }
}
