import SwiftUI

struct SignUpInputView: View {
    @ObservedObject var viewModel: SignUpViewModel

    var body: some View {
        VStack(spacing: 16) {
            Group {
                // First Name
                VStack(alignment: .leading, spacing: 4) {
                    InputField(placeholder: "First Name (max 10 chars)", text: $viewModel.firstName, isSecure: false, hasError: viewModel.isFirstNameTooLong)
                        .textContentType(.givenName)
                    
                    if viewModel.isFirstNameTooLong {
                        Text("Too long. 10 max length")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Last Name
                InputField(placeholder: "Last Name", text: $viewModel.lastName, isSecure: false)
                    .textContentType(.familyName)

                // Email
                VStack(alignment: .leading, spacing: 4) {
                    InputField(
                        placeholder: "Email", 
                        text: $viewModel.email, 
                        isSecure: false, 
                        hasError: !viewModel.email.isEmpty && !viewModel.isValidEmail
                    )
                    .textContentType(.emailAddress)
                    
                    if !viewModel.email.isEmpty && !viewModel.isValidEmail {
                        Text("Invalid email address")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Password
                InputField(placeholder: "Password (min 6 chars)", text: $viewModel.password, isSecure: true)
                    // ✨ THE FIX: Change to .password to disable strong password suggestion
                    .textContentType(.password)
                
                // Confirm Password
                VStack(alignment: .leading, spacing: 4) {
                    InputField(
                        placeholder: "Confirm Password", 
                        text: $viewModel.confirmPassword, 
                        isSecure: true,
                        hasError: !viewModel.confirmPassword.isEmpty && !viewModel.passwordsMatch
                    )
                    .textContentType(.password)
                    
                    if !viewModel.confirmPassword.isEmpty && !viewModel.passwordsMatch {
                        Text("Passwords don't match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .autocapitalization(.none)

            Button("Next: Choose Username") {
                viewModel.submitStep1()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentColor)
            .cornerRadius(6) // Less rounded corners
            .disabled(!viewModel.isStep1Valid || viewModel.isLoading)
            .padding(.top, 16)
        }
    }
}

// ✨ NEW HELPER: Extension to create a Binding that automatically cleans whitespace
// This requires a simple extension to make .clean available on the Binding<String>
extension Binding where Value == String {
    var clean: Binding<String> {
        return Binding<String>(
            get: { self.wrappedValue },
            set: {
                // Trim the whitespace and newlines when setting the value
                self.wrappedValue = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        )
    }
}
