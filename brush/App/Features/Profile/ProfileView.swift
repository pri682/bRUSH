
import SwiftUI

struct ProfileView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false
    @StateObject private var auth = AuthService.shared

    var body: some View {
        NavigationStack {
            Group {
                if let user = auth.user {
                    VStack(spacing: 16) {
                        Text("Welcome\(user.displayName.map { " \($0)" } ?? ", \(user.email)")")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isSignUp ? "Create an account" : "Sign in")
                            .font(.title2.bold())

                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                        Button {
                            Task {
                                if isSignUp {
                                    await auth.signUp(email: email, password: password)
                                } else {
                                    await auth.signIn(email: email, password: password)
                                }
                            }
                        } label: {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)

                        Button {
                            Task { await auth.signInWithGoogle() }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "g.circle")
                                Text("Continue with Google")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            isSignUp.toggle()
                        } label: {
                            HStack {
                                Text(isSignUp ? "Already have an account?" : "New here?")
                                Text(isSignUp ? "Sign In" : "Create one")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
        }
    }
}
