import SwiftUI

struct SignUpUsernameView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your display name is how other users will see you.")
                .font(.subheadline)
                .multilineTextAlignment(.center)

            // Display Name Input Field
            VStack(alignment: .leading, spacing: 4) {
                InputField(
                    placeholder: "Display Name (3-15 chars, letters/numbers/_ only)",
                    text: $viewModel.displayName,
                    isSecure: false,
                    hasError: viewModel.isDisplayNameTooLong || viewModel.isDisplayNameInvalidFormat
                )
                
                if viewModel.isDisplayNameTooLong {
                    Text("Too long. 15 max length")
                        .font(.caption)
                        .foregroundColor(.red)
                } else if viewModel.isDisplayNameInvalidFormat {
                    Text("Invalid characters. Only letters, numbers, and _ allowed")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            // 🗑️ REMOVED: .onChange logic, as validation is no longer required on type
            
            // Display error message for validation issues
            if !viewModel.displayName.isEmpty && !viewModel.isStep2Valid {
                if viewModel.displayName.count < 3 {
                    Text("Display name must be at least 3 characters.")
                        .foregroundColor(.red)
                } else if viewModel.displayName.count > 15 {
                    Text("Display name must be 15 characters or less.")
                        .foregroundColor(.red)
                } else {
                    Text("Display name can only contain letters, numbers, and underscores.")
                        .foregroundColor(.red)
                }
            }
            
            // Display general error message from ViewModel
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            // 🗑️ REMOVED: All status indicators related to checking unique name

            Button("Next: Create Avatar") {
                // Calls the updated submitStep2() in the ViewModel (no longer async)
                viewModel.submitStep2()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)
            .disabled(
                // SIMPLIFIED disable logic
                !viewModel.isStep2Valid ||
                viewModel.isLoading
            )
        }
        .padding(.horizontal) // Add padding to make the view look good
    }
}
