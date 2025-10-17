import SwiftUI

struct EditProfileView: View {
    @Binding var userProfile: UserProfile?
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    init(userProfile: Binding<UserProfile?>) {
        self._userProfile = userProfile
        _viewModel = StateObject(
            wrappedValue: EditProfileViewModel(userProfile: userProfile.wrappedValue!)
        )
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Bar
                HStack(spacing: 0) {
                    ForEach(0..<2) { index in
                        Button {
                            selectedTab = index
                        } label: {
                            VStack(spacing: 8) {
                                Text(index == 0 ? "Profile Information" : "Avatar")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedTab == index ? .blue : .gray)
                                
                                Rectangle()
                                    .fill(selectedTab == index ? Color.blue : Color.clear)
                                    .frame(height: 3)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .background(Color(.systemGray6))
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // Profile Information Tab
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
                    .tag(0)
                    
                    // Avatar Tab
                    EditAvatarView(userProfile: $userProfile)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
