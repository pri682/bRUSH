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

    // MARK: - State Management
    @Published var currentStep: SignUpStep = .input
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Validation Properties
    var isValidEmail: Bool {
        email.contains("@") && email.contains(".")
    }
    
    var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    // 🔑 KAN-157: Property for basic length validation on password
    var isPasswordTooShort: Bool {
        return !password.isEmpty && password.count < 6
    }

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
        return !firstName.isEmpty && firstName.count <= 10 && !lastName.isEmpty && email.contains("@") && password.count >= 6 && password == confirmPassword
    }

    func submitStep1() {
        guard isStep1Valid else {
            if firstName.count > 10 {
                errorMessage = "First name must be 10 characters or less."
            } else {
                errorMessage = "Please ensure all fields are filled correctly, email is valid, and passwords match (min 6 characters)."
            }
            return
        }
        // Navigate to the next step
        errorMessage = nil
        currentStep = .username
    }
    
    // 🔑 ADDED: Property for basic length validation on Step 2
    var isStep2Valid: Bool {
        return displayName.count >= 3 && displayName.count <= 15 && isValidUsername(displayName)
    }
    
    // Helper function to validate username format (letters, numbers, underscores only)
    private func isValidUsername(_ username: String) -> Bool {
        let allowedChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        return allowedChars.isSuperset(of: CharacterSet(charactersIn: username))
    }
    
    // Real-time validation properties for UI feedback
    var isFirstNameTooLong: Bool {
        return firstName.count > 10
    }
    
    var isDisplayNameTooLong: Bool {
        return displayName.count > 15
    }
    
    var isDisplayNameInvalidFormat: Bool {
        return !displayName.isEmpty && !isValidUsername(displayName)
    }

    // MARK: - Step 2 Display Name Validation
    
    // ✨ NEW/MODIFIED: Submit function for Step 2 (navigates to avatar step)
    func submitStep2() {
        guard isStep2Valid else {
            if displayName.count < 3 {
                errorMessage = "Username must be at least 3 characters."
            } else if displayName.count > 15 {
                errorMessage = "Username must be 15 characters or less."
            } else if !isValidUsername(displayName) {
                errorMessage = "Username can only contain letters, numbers, and underscores."
            }
            return
        }
        
        // Navigate to avatar step
        errorMessage = nil
        currentStep = .avatar
    }
    
    // MARK: - Step 3 Avatar Selection
    
    func submitStep3() async { // wait for step 3 - avatar completion
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
                    avatarType: selectedAvatar?.avatarType.rawValue ?? "personal",
                    avatarBackground: selectedAvatar?.background,
                    avatarBody: selectedAvatar?.body,
                    avatarShirt: selectedAvatar?.shirt,
                    avatarEyes: selectedAvatar?.eyes,
                    avatarMouth: selectedAvatar?.mouth,
                    avatarHair: selectedAvatar?.hair,
                    avatarFacialHair: selectedAvatar?.facialHair,
                    // Initialize all medal and statistics fields to 0
                    goldMedalsAccumulated: 0,
                    silverMedalsAccumulated: 0,
                    bronzeMedalsAccumulated: 0,
                    goldMedalsAwarded: 0,
                    silverMedalsAwarded: 0,
                    bronzeMedalsAwarded: 0,
                    totalDrawingCount: 0,
                    streakCount: 0,
                    memberSince: Date()
                )

                // DEBUG: print the profile payload keys/values before saving to Firestore.
                // This helps verify that avatarHair / avatarMouth / etc. are present and correctly named.
                do {
                    let mirror = Mirror(reflecting: profile)
                    let fields = mirror.children.compactMap { child in
                        if let label = child.label {
                            return "\(label)=\(String(describing: child.value))"
                        }
                        return nil
                    }.joined(separator: ", ")
                    print("[DEBUG] Creating UserProfile -> \(fields)")
                } catch {
                    print("[DEBUG] Creating UserProfile -> (failed to reflect): \(error)")
                }

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
