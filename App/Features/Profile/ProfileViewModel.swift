import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var user: AppUser? = nil
    @Published var errorMessage: String? = nil

    private let auth = AuthService.shared
    private var cancellables = Set<AnyCancellable>() // Used for Combine subscriptions

    init() {
        // ✨ THE FIX: Use .sink instead of .assign(to: &$) for reliable chaining in init()
        auth.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newUser in
                // Safely update the @Published property inside the sink closure
                self?.user = newUser
            }
            .store(in: &cancellables)
    }

    // 💡 HELPER: Basic email validation
    private func validateEmail() throws {
        if !email.contains("@") {
            // Assuming AuthError.invalidEmailFormat is defined in an extension
            throw AuthError.invalidEmailFormat
        }
    }

    func signIn() async {
        errorMessage = nil
        do {
            try validateEmail()
            try await auth.signIn(email: email, password: password)
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
                self.email = ""
                self.password = ""
            }
        }
    }
    
    func deleteProfile() async {
        errorMessage = nil
        do {
            try await auth.deleteUser()
            // Clear local state on successful deletion
            self.user = nil
            self.email = ""
            self.password = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

// Ensure this extension is available in the scope where ProfileViewModel is defined
public extension AuthError {
    static var invalidEmailFormat: AuthError {
        return .backend("Invalid email address.")
    }
}
