import SwiftUI
import Combine
import FirebaseAuth


struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let user = viewModel.user {
                    VStack(spacing: 16) {
                        Text("Welcome\(user.displayName.map { " \($0)" } ?? ", \(user.email)")")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                        
                        Button("Sign Out") {
                            viewModel.signOut() }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                    .padding()
                }
                    else {
                    VStack(spacing: 20) {
                        Spacer()

                        Text(viewModel.isSignUp ? "Create an account" : "Sign in")
                            .font(.title2.bold())

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
                            Task {
                                if viewModel.isSignUp {
                                    await viewModel.signUp()
                                } else {
                                    await viewModel.signIn()
                                }
                            }
                        } label: {
                            Text(viewModel.isSignUp ? "Sign Up" : "Sign In")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)

                        DividerWithText("or")

//                        GoogleSignInButton {
//                            Task { await viewModel.signInWithGoogle() }
//                        }

                        Spacer()

                        Button {
                            viewModel.toggleSignUp()
                        } label: {
                            HStack {
                                Text(viewModel.isSignUp ? "Already have an account?" : "Don’t have an account?")
                                Text(viewModel.isSignUp ? "Sign In" : "Sign Up")
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
        }
    }
}
