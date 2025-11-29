import SwiftUI

struct SignUpUsernameView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Your username is how other users will find you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                InputField(
                    placeholder: "Username",
                    text: $viewModel.displayName,
                    isSecure: false,
                    hasError: validationMessage != nil,
                    textContentType: .username
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                Group {
                    if let error = validationMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                            Text(error)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.red)
                    } else {
                        Text("3-15 characters. Letters, numbers, and underscores only.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading, 4)
                .animation(.easeInOut(duration: 0.2), value: validationMessage)
            }

            Button("Next: Create Avatar") {
                viewModel.submitStep2()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .disabled(!viewModel.isStep2Valid || viewModel.isLoading)
            .buttonStyle(.glassProminent)
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var validationMessage: String? {
        if viewModel.displayName.isEmpty { return nil }
        
        if viewModel.isDisplayNameTooLong {
            return "Too long. Maximum 15 characters."
        }
        if viewModel.isDisplayNameInvalidFormat {
            return "Invalid format. Letters, numbers, and '_' only."
        }
        if viewModel.displayName.count < 3 {
            return "Too short. Minimum 3 characters."
        }
        
        return viewModel.errorMessage
    }
}
