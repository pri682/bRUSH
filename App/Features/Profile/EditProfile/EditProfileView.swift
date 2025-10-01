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

                    if let error = viewModel.errorMessage {
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
                            await viewModel.saveChanges()
                            if viewModel.errorMessage == nil {
                                // Push changes back into parent
                                if var updated = userProfile {
                                    updated.firstName = viewModel.firstName
                                    userProfile = updated
                                }
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }
}
