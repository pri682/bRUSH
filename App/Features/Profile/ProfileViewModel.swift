import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var user: AppUser? = nil
    @Published var profile: UserProfile? = nil   // 🔥 New: Firestore profile
    @Published var errorMessage: String? = nil

    private let auth = AuthService.shared
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Watch for auth state changes
        auth.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newUser in
                self?.user = newUser
                Task {
                    if let uid = newUser?.id {
                        await self?.loadProfile(uid: uid)
                    } else {
                        await MainActor.run {
                            self?.profile = nil
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Profile Loading
    private func loadProfile(uid: String) async {
        do {
            let loadedProfile = try await UserService.shared.fetchProfile(uid: uid)
            await MainActor.run { self.profile = loadedProfile }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
        }
    }

    // MARK: - Email Validation
    private func validateEmail() throws {
        if !email.contains("@") {
            throw AuthError.invalidEmailFormat
        }
    }

    // MARK: - Auth Actions
    func signIn() async {
        errorMessage = nil
        do {
            try validateEmail()
            try await auth.signIn(email: email, password: password)
            if let uid = auth.user?.id {
                await loadProfile(uid: uid)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        Task {
            await auth.signOut()
            await MainActor.run {
                self.user = nil
                self.profile = nil
                self.errorMessage = nil
                self.email = ""
                self.password = ""
                LocalUserStorage.shared.clearProfile()
            }
        }
    }
    
    func deleteProfile() async {
        errorMessage = nil
        do {
            guard let currentUser = user else {
                errorMessage = "No user to delete"
                return
            }
            
            // Delete from Firestore first
            try await UserService.shared.deleteProfile(uid: currentUser.id)
            
            // Then delete from Firebase Auth
            try await auth.deleteUser()
            
            // Clear local state
            self.user = nil
            self.profile = nil
            self.email = ""
            self.password = ""
            LocalUserStorage.shared.clearProfile()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updateFirstName(_ newFirstName: String) async {
        guard let userID = user?.id else { return } // Ensure we use the correct property for user ID
        do {
            try await db.collection("users").document(userID).updateData(["firstName": newFirstName])
            DispatchQueue.main.async {
                self.profile?.firstName = newFirstName // Ensure `firstName` is mutable
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to update name: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Custom Error
public extension AuthError {
    static var invalidEmailFormat: AuthError {
        return .backend("Invalid email address.")
    }
}
