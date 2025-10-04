import SwiftUI

struct SignInProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingSignUpFlow = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Sign In")
                .font(.title2.bold())

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.opacity)
            }

            InputField(placeholder: "Email", text: $viewModel.email, isSecure: false)
            InputField(placeholder: "Password", text: $viewModel.password, isSecure: true)

            Button {
                Task { await viewModel.signIn() }
            } label: {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)

            Spacer()

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
        .sheet(isPresented: $showingSignUpFlow) {
            SignUpFlow()
        }
    }
}
