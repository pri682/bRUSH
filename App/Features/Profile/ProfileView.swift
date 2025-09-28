import SwiftUI
import Combine
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var localStorage = LocalUserStorage.shared
    // ✨ NEW: State to manage the Sheet presentation for sign-up
    @State private var showingSignUpFlow = false

    var body: some View {
        NavigationStack {
            Group {
                if let user = viewModel.user {
                    VStack(spacing: 16) {
                        // Display first name and username from local storage
                        if let profile = localStorage.currentProfile {
                            VStack(spacing: 4) {
                                Text(profile.firstName)
                                    .font(.title.bold())
                                    .multilineTextAlignment(.center)
                                
                                Text("@\(profile.displayName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            // Show loading or prompt to set up profile
                            VStack(spacing: 4) {
                                Text("Welcome!")
                                    .font(.title.bold())
                                    .multilineTextAlignment(.center)
                                
                                Text("Setting up your profile...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                            
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
