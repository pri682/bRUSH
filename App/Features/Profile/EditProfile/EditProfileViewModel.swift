import Foundation
import Combine
import SwiftUI

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var firstName: String
    @Published var displayName: String
    @Published var firstNameError: String?
    @Published var displayNameError: String?
    @Published private(set) var isSaving = false

    private let userProfile: UserProfile

    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        self.firstName = userProfile.firstName
        self.displayName = userProfile.displayName
    }

    var isValid: Bool {
        validateFirstName() == nil && validateDisplayName() == nil
    }

    /// Save changes to Firestore
    func saveChanges() async -> Bool {
        // Validate before save
        firstNameError = validateFirstName()
        displayNameError = validateDisplayName()

        guard firstNameError == nil, displayNameError == nil else {
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await UserService.shared.updateProfile(
                uid: userProfile.uid,
                data: [
                    "firstName": firstName,
                    "displayName": displayName   // ✅ match your UserProfile struct + Firestore field
                ]
            )
            return true
        } catch {
            firstNameError = "Failed to save: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Validation
    private func validateFirstName() -> String? {
        let trimmed = firstName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "First name cannot be empty." }
        guard trimmed.count >= 3 else { return "First name must be at least 3 characters long." }
        guard trimmed.count <= 20 else { return "First name cannot be more than 20 characters long." }
        return nil
    }

    private func validateDisplayName() -> String? {
        let trimmed = displayName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "Username cannot be empty." }
        guard trimmed.count >= 3 else { return "Username must be at least 3 characters long." }
        guard trimmed.count <= 15 else { return "Username cannot be more than 15 characters long." }
        guard CharacterSet.alphanumerics.isSuperset(of: CharacterSet(charactersIn: trimmed)) else {
            return "Username can only contain letters and numbers."
        }
        return nil
    }
}
