import SwiftUI

struct SignUpFlow: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.currentStep == .input {
                    SignUpInputView(viewModel: viewModel)
                } else {
                    SignUpUsernameView(viewModel: viewModel)
                }

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity)
                }
            }
            .padding()
            .navigationTitle(viewModel.currentStep == .input ? "Create Account" : "Choose Display Name")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // 💡 TODO: Dismiss the flow when sign up is complete (AuthService publishes new user)
        }
    }
}
