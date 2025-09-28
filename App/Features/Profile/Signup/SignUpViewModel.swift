import Foundation
import Combine
import FirebaseAuth // For error handling contexts

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
    @Published var isCheckingDisplayName = false
    @Published var displayNameError: String? = nil

    // MARK: - State Management
    @Published var currentStep: SignUpStep = .input
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let auth = AuthService.shared
    private let userService = UserService.shared
    
    enum SignUpStep {
        case input      // First Name, Last Name, Email, Passwords
        case username   // Choose Display Name
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
    
    // MARK: - Step 2 Display Name Validation

    func validateDisplayName() async {
        displayNameError = nil
        isCheckingDisplayName = true
        
        guard displayName.count >= 3 else {
            displayNameError = "Display name must be at least 3 characters."
            isCheckingDisplayName = false
            return
        }

        do {
            let isTaken = try await userService.isDisplayNameTaken(displayName)
            if isTaken {
                displayNameError = "This display name is already taken. Please choose another."
            } else {
                displayNameError = nil
            }
        } catch {
            displayNameError = "Failed to check display name availability. Please try again."
        }
        isCheckingDisplayName = false
    }

    // MARK: - Final Sign Up Execution (Auth + Firestore)

    func completeSignUp() async {
        guard displayNameError == nil && !displayName.isEmpty else {
            errorMessage = "Please enter a valid, unique display name."
            return
        }
        
        isLoading = true
        errorMessage = nil

        do {
            // 1. Create the user in Firebase Auth (Email/Password)
            let authUser = try await auth.signUp(email: email, password: password)
            
            // 2. Prepare the full profile object for Firestore
            let profile = UserProfile(
                uid: authUser.id,
                firstName: firstName,
                lastName: lastName,
                displayName: displayName,
                email: email
            )
            
            // 3. Save the profile to Firestore (includes the unique display name check/lock)
            try await userService.createProfile(userProfile: profile)
            
            // Success: The user is now signed in and their data is saved.
            // We can now dismiss the flow or rely on the AuthService to update the main UI.

        } catch let authError as AuthError {
            // Handle Auth-related errors (e.g., email already in use)
            errorMessage = authError.errorDescription
            // If Auth failed, roll back the step to let the user correct the email/password
            currentStep = .input
        } catch {
            // Handle Firestore/UserService errors (e.g., network failure, or rare display name race condition)
            errorMessage = "Sign up failed: \(error.localizedDescription)"
            
            // 💡 CRITICAL: If Firestore fails *after* Auth succeeds, you have a partial registration.
            // In a production app, you would add logic here to clean up the Auth user if Firestore failed.
            // For simplicity here, we rely on the main error message.
        }
        
        isLoading = false
    }
}
