import SwiftUI

struct SignUpUsernameView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your display name is how other users will see you.")
                .font(.subheadline)
                .multilineTextAlignment(.center)

            // Display Name Input Field
            InputField(
                placeholder: "Display Name (Unique)",
                text: $viewModel.displayName,
                isSecure: false
            )
            .onChange(of: viewModel.displayName) { _ in
                // Debounce or manually trigger validation
                Task {
                    // Simple check when text changes, a real app might debounce this
                    await viewModel.validateDisplayName()
                }
            }
            
            // Display Name Status/Error
            if viewModel.isCheckingDisplayName {
                ProgressView("Checking...")
            } else if let error = viewModel.displayNameError {
                Text(error)
                    .foregroundColor(.red)
            } else if !viewModel.displayName.isEmpty {
                Text("Display name is available!")
                    .foregroundColor(.green)
            }

            Button("Complete Sign Up") {
                Task {
                    await viewModel.completeSignUp()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)
            .disabled(
                viewModel.displayName.isEmpty ||
                viewModel.displayNameError != nil ||
                viewModel.isCheckingDisplayName ||
                viewModel.isLoading
            )
        }
    }
}
