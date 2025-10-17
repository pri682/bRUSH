import Foundation
import Combine
import SwiftUI // Required for @MainActor and ObservableObject
// import FirebaseAuth // Keep if AuthError is defined here, otherwise remove

@MainActor
class SignUpViewModel: ObservableObject {
    // MARK: - Step 1 Fields (InputView)
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    // MARK: - Step 2 Fields (UsernameView)
    @Published var displayName = ""
    
    // MARK: - Step 3 Fields (AvatarView)
    @Published var selectedAvatar: AvatarParts? = nil
    
    // 🗑️ REMOVED: isCheckingDisplayName (No longer needed)
    // 🗑️ REMOVED: displayNameError (No longer needed since uniqueness check is gone)

    // MARK: - State Management
    @Published var currentStep: SignUpStep = .input
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let auth = AuthService.shared
    private let userService = UserService.shared
    
    enum SignUpStep {
        case input      // First Name, Last Name, Email, Passwords
        case username   // Choose Display Name
        case avatar     // Choose Avatar
        case complete   // ✨ ADDED: Final step for flow control
    }

    // MARK: - Step 1 Validation & Navigation

    var isStep1Valid: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && email.contains("@") && password.count >= 6 && password == confirmPassword
    }

    func submitStep1() {
        guard isStep1Valid else {
            errorMessage = "Please ensure all fields are filled correctly, email is valid, and passwords match (min 6 characters)."
            return
        }
        // Navigate to the next step
        errorMessage = nil
        currentStep = .username
    }
    
    // 🔑 ADDED: Property for basic length validation on Step 2
    var isStep2Valid: Bool {
        return displayName.count >= 3
    }

    // MARK: - Step 2 Display Name Validation

    // 🗑️ REMOVED: The entire async validateDisplayName() function.
    
    // ✨ NEW/MODIFIED: Submit function for Step 2 (navigates to avatar step)
    func submitStep2() {
        guard isStep2Valid else {
            errorMessage = "Username must be at least 3 characters."
            return
        }
        
        errorMessage = nil
        currentStep = .avatar
    }
    
    // MARK: - Step 3 Avatar Selection
    
    func submitStep3() async {
        await completeSignUp()
    }
    
    func skipPhotoStep() async {
        await completeSignUp()
    }

    // MARK: - Final Sign Up Execution (Auth + Firestore)

    func completeSignUp() async {
        // 🔑 MODIFIED: Simplified guard to only check for length using isStep2Valid
        guard isStep2Valid else {
            errorMessage = "Please enter a valid display name (min 3 characters)."
            return
        }
        
        isLoading = true
        errorMessage = nil

        do {
                // 1. Create the user in Firebase Auth (Email/Password)
                let authUser = try await auth.signUp(email: email, password: password)
                
                // 2. Prepare and Save the full profile object to Firestore
                let profile = UserProfile(
                    uid: authUser.id,
                    firstName: firstName,
                    lastName: lastName,
                    displayName: displayName,
                    email: email,
                    avatarBackground: selectedAvatar?.background,
                    avatarFace: selectedAvatar?.face,
                    avatarEyes: selectedAvatar?.eyes,
                    avatarMouth: selectedAvatar?.mouth,
                    avatarHair: selectedAvatar?.hair,
                    // Initialize all medal and statistics fields to 0
                    goldMedalsAccumulated: 0,
                    silverMedalsAccumulated: 0,
                    bronzeMedalsAccumulated: 0,
                    goldMedalsAwarded: 0,
                    silverMedalsAwarded: 0,
                    bronzeMedalsAwarded: 0,
                    totalDrawingCount: 0,
                    streakCount: 0
                )
                try await userService.createProfile(userProfile: profile)
                
                // 3. Save profile locally for fast access
                let localProfile = LocalUserProfile(
                    firstName: firstName,
                    lastName: lastName,
                    displayName: displayName,
                    email: email,
                    uid: authUser.id
                )
                LocalUserStorage.shared.saveProfile(localProfile)
                
                // Sign-up successful - AuthService.signUp already updated the user state
                // Set state to .complete (for dismissing the sign up flow UI)
                currentStep = .complete

            } catch let authError as AppAuthError {
                errorMessage = authError.localizedDescription
            } catch {
                errorMessage = "Sign up failed: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
}
