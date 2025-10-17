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
                InputField(placeholder: "Email", text: $viewModel.email, isSecure: false)
                    .textContentType(.emailAddress)
                
                // Password
                InputField(placeholder: "Password (min 6 chars)", text: $viewModel.password, isSecure: true)
                    // ✨ THE FIX: Change to .password to disable strong password suggestion
                    .textContentType(.password)
                
                // Confirm Password
                InputField(placeholder: "Confirm Password", text: $viewModel.confirmPassword, isSecure: true)
                    // ✨ THE FIX: Change to .password
                    .textContentType(.password)
            }
            .autocapitalization(.none)

            Button("Next: Choose Username") {
                viewModel.submitStep1()
            }
            .buttonStyle(.borderedProminent)
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
