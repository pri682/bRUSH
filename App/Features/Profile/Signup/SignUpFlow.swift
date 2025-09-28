import SwiftUI

struct SignUpFlow: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Monitor authentication state to auto-dismiss when signed up
    @StateObject private var auth = AuthService.shared

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.currentStep == .input {
                    SignUpInputView(viewModel: viewModel)
                } else if viewModel.currentStep == .username {
                    SignUpUsernameView(viewModel: viewModel)
                } else {
                    // Sign-up complete - show success message briefly
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Welcome to Brush!")
                            .font(.title2.bold())
                        
                        Text("Your account has been created successfully.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
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
            .navigationTitle(
                viewModel.currentStep == .input ? "Create Account" : 
                viewModel.currentStep == .username ? "Choose Display Name" : 
                "Welcome!"
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: auth.user) { _, newUser in
                // Auto-dismiss when user is successfully signed up
                if newUser != nil && viewModel.currentStep == .complete {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            }
        }
    }
}
