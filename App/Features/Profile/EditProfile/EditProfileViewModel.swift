import Foundation
import Combine
import SwiftUI


@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var firstName: String
    @Published var errorMessage: String?
    @Published private(set) var isSaving = false

    private let userProfile: UserProfile

    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        self.firstName = userProfile.firstName
    }

    /// Returns true if changes saved successfully
    func saveChanges() async -> Bool {
        // Validation
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "First name cannot be empty."
            return false
        }
        guard firstName.count >= 3 else {
            errorMessage = "First name must be at least 3 characters long."
            return false
        }
        guard firstName.count <= 20 else {
            errorMessage = "First name cannot be more than 20 characters long."
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await UserService.shared.updateProfile(
                uid: userProfile.uid,
                data: ["firstName": firstName]
            )
            return true
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            return false
        }
    }
}
