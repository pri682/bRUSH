import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSignUp: Bool = false
    @Published private(set) var user: AppUser? = nil
    @Published var errorMessage: String? = nil // Remains for UI display

    private let auth = AuthService.shared

    init() {
        self.user = auth.user
    }

    func toggleSignUp() {
        isSignUp.toggle()
        errorMessage = nil
    }
    
    // 💡 NEW HELPER: Basic email validation
    private func validateEmail() throws {
        if !email.contains("@") {
            throw AuthError.invalidEmailFormat
        }
    }

    func signIn() async {
        errorMessage = nil
        do {
            try validateEmail() // Validate before calling service
            try await auth.signIn(email: email, password: password)
            self.user = auth.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signUp() async {
        errorMessage = nil
        do {
            try validateEmail() // Validate before calling service
            try await auth.signUp(email: email, password: password)
            self.user = auth.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        Task {
            await auth.signOut()
            await MainActor.run {
                self.user = nil
                self.errorMessage = nil
            }
        }
    }
}

// 💡 NEW: Add AuthError case for email validation
public extension AuthError {
    static var invalidEmailFormat: AuthError {
        return .backend("Invalid email address.")
    }
}
