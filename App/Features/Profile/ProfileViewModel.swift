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
            // Load local profile data if available
            LocalUserStorage.shared.loadProfile()
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
                // Clear local storage
                LocalUserStorage.shared.clearProfile()
            }
        }
    }
    
    func deleteProfile() async {
        errorMessage = nil
        do {
            // Get user ID before deletion
            guard let currentUser = user else {
                errorMessage = "No user to delete"
                return
            }
            
            // Delete from Firestore first
            try await UserService.shared.deleteProfile(uid: currentUser.id)
            
            // Then delete from Firebase Auth
            try await auth.deleteUser()
            
            // Clear local state and storage on successful deletion
            self.user = nil
            self.email = ""
            self.password = ""
            LocalUserStorage.shared.clearProfile()
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
