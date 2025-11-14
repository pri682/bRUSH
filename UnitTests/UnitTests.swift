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


struct UnitTests {

//    @Test func example() async throws {
//        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//    }

}
