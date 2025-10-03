import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingSignUpFlow = false
    @State private var showingEditProfile = false

    var body: some View {
        NavigationStack {
            Group {
                if let user = viewModel.user {
                    VStack(spacing: 16) {
                        // Display first name and username from Firestore profile
                        if let _ = viewModel.profile {
                            VStack(spacing: 4) {
                                HStack {
                                    Text(viewModel.profile!.firstName)
                                        .font(.title.bold())
                                        .multilineTextAlignment(.center)

                                    Button {
                                        showingEditProfile = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                }

                                Text("@\(viewModel.profile!.displayName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            // Show loading or placeholder while fetching
                            VStack(spacing: 4) {
                                Text("Welcome!")
                                    .font(.title.bold())
                                    .multilineTextAlignment(.center)

                                Text("Loading your profile...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        // Example streak section
                        VStack(spacing: 8) {
                            Text("🔥 Current Streak: \(StreakManager().currentStreak) days")
                                .font(.headline)
                            Text("🏆 Longest Streak: \(StreakManager().longestStreak) days")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 12)

                        // Sign Out
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
                } else {
                    // Sign In screen
                    VStack(spacing: 20) {
                        Spacer()

                        Text("Sign In")
                            .font(.title2.bold())

                        // Error message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity)
                        }

                        // Email
                        InputField(
                            placeholder: "Email",
                            text: $viewModel.email,
                            isSecure: false
                        )

                        // Password
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

                        Spacer()

                        // Launch Sign Up Flow
                        Button {
                            showingSignUpFlow = true
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
            .sheet(isPresented: $showingSignUpFlow) {
                SignUpFlow()
            }
            .sheet(isPresented: $showingEditProfile) {
                if let _ = viewModel.profile {
                    EditProfileView(userProfile: $viewModel.profile)
                }
            }

        }
    }
}
