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
    @Published var isLoadingProfile: Bool = false

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
        await MainActor.run { self.isLoadingProfile = true }
        
        // Set up timeout for profile loading
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
            await MainActor.run {
                if self.isLoadingProfile {
                    // If still loading after 10 seconds, sign out user
                    self.signOut()
                    self.errorMessage = "Account not found. Please sign in again."
                }
            }
        }
        
        do {
            let loadedProfile = try await UserService.shared.fetchProfile(uid: uid)
            timeoutTask.cancel() // Cancel timeout if profile loads successfully
            await MainActor.run { 
                self.profile = loadedProfile
                self.isLoadingProfile = false
            }
        } catch {
            timeoutTask.cancel() // Cancel timeout on error
            await MainActor.run { 
                // Check if the error is "Profile not found" and sign out user
                if error.localizedDescription.contains("Profile not found") {
                    self.signOut()
                    self.errorMessage = "Account not found. Please sign in again."
                } else {
                    self.errorMessage = error.localizedDescription
                }
                self.isLoadingProfile = false
            }
        }
    }
    
    // MARK: - Public Refresh Method
    func refreshProfile() async {
        guard let uid = user?.id else { return }
        await loadProfile(uid: uid)
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
            await MainActor.run {
                self.user = nil
                self.profile = nil
                self.email = ""
                self.password = ""
                LocalUserStorage.shared.clearProfile()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
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
