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
                } else if viewModel.currentStep == .avatar {
                    SignUpAvatarView(viewModel: viewModel)
                } else {
                    // Sign-up complete - show success message with Continue button
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Welcome to Brush!")
                            .font(.title2.bold())
                        
                        Text("Your account has been created successfully.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Continue") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 32)
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
                // Only show Cancel button during sign-up steps, not on welcome screen
                if viewModel.currentStep != .complete {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            // Note: Manual Continue button now handles dismissal instead of auto-dismiss
        }
    }
}
