import SwiftUI
import Combine
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    // ✨ NEW: State to manage the Sheet presentation for sign-up
    @State private var showingSignUpFlow = false

    var body: some View {
        NavigationStack {
            Group {
                if let user = viewModel.user {
                    VStack(spacing: 16) {
                        // Display user's Display Name if available, otherwise email
                        Text("Welcome\(user.displayName.map { " \($0)" } ?? ", \(user.email ?? "user")")")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                            
                        Button("Sign Out!") {
                            viewModel.signOut()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .padding(.top, 8)
                        
                        // Delete Profile Button
                        DeleteProfileButton(viewModel: viewModel)
                    }
                    .padding()
                }
                else {
                    VStack(spacing: 20) {
                        Spacer()

                        // Only for Sign In now
                        Text("Sign In")
                            .font(.title2.bold())

                        // Error Message Display
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity)
                        }

                        // Input fields for SIGN IN
                        InputField(
                            placeholder: "Email",
                            text: $viewModel.email,
                            isSecure: false
                        )

                        InputField(
                            placeholder: "Password",
                            text: $viewModel.password,
                            isSecure: true
                        )

                        Button {
                            Task { await viewModel.signIn() }
                        } label: {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)

                        // NOTE: DividerWithText must be defined elsewhere
                        // DividerWithText("or")

                        Spacer()

                        // ✨ NEW: Button to launch the multi-step SignUpFlow
                        Button {
                            showingSignUpFlow = true // Open the sheet
                        } label: {
                            HStack {
                                Text("Don’t have an account?")
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 12)
                    }
                    .frame(maxWidth: 340)
                    .padding()
                }
            }
            .navigationTitle("Profile")
            // ✨ NEW: The sheet modifier to present the SignUpFlow
            .sheet(isPresented: $showingSignUpFlow) {
                SignUpFlow()
            }
        }
    }
}
