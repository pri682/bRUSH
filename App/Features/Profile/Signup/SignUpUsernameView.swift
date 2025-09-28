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
                placeholder: "Display Name (min 3 chars)",
                text: $viewModel.displayName,
                isSecure: false
            )
            // 🗑️ REMOVED: .onChange logic, as validation is no longer required on type
            
            // Display a simple error message if the name is too short
            if !viewModel.displayName.isEmpty && !viewModel.isStep2Valid {
                 Text("Display name must be at least 3 characters.")
                    .foregroundColor(.red)
            }

            // 🗑️ REMOVED: All status indicators related to checking unique name

            Button("Complete Sign Up") {
                Task {
                    // Calls the updated submitStep2() in the ViewModel
                    await viewModel.submitStep2()
                }
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
