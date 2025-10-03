import SwiftUI

struct EditProfileView: View {
    @Binding var userProfile: UserProfile?
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss

    init(userProfile: Binding<UserProfile?>) {
        self._userProfile = userProfile
        _viewModel = StateObject(
            wrappedValue: EditProfileViewModel(userProfile: userProfile.wrappedValue!)
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("First Name")) {
                    TextField("Enter your first name", text: $viewModel.firstName)
                        .autocapitalization(.words)

                    if let error = viewModel.firstNameError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section(header: Text("Username")) {
                    TextField("Enter your username", text: $viewModel.displayName)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)

                    if let error = viewModel.displayNameError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let success = await viewModel.saveChanges()
                            if success {
                                // Push changes back into parent binding
                                if var updated = userProfile {
                                    updated.firstName = viewModel.firstName
                                    updated.displayName = viewModel.displayName
                                    userProfile = updated
                                }
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving || !viewModel.isValid)
                }

            }
        }
    }
}
