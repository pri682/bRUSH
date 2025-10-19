import SwiftUI

struct EditProfileView: View {
    @Binding var userProfile: UserProfile?
    @ObservedObject var profileViewModel: ProfileViewModel
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingDeleteConfirmation = false
    @State private var currentAvatarParts: AvatarParts?

    init(userProfile: Binding<UserProfile?>, profileViewModel: ProfileViewModel) {
        self._userProfile = userProfile
        self.profileViewModel = profileViewModel
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
                                    .foregroundColor(selectedTab == index ? .accentColor : .gray)
                                
                                Rectangle()
                                    .fill(selectedTab == index ? Color.accentColor : Color.clear)
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
                    VStack(spacing: 16) {
                        // First Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.headline)
                            InputField(
                                placeholder: "Enter your first name (max 10 chars)",
                                text: $viewModel.firstName,
                                isSecure: false,
                                hasError: viewModel.isFirstNameTooLong
                            )
                            .autocapitalization(.words)
                            
                            if viewModel.isFirstNameTooLong {
                                Text("Too long. 10 max length")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else if let error = viewModel.firstNameError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        // Username
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                            InputField(
                                placeholder: "Enter your username (3-15 chars, letters/numbers/_ only)",
                                text: $viewModel.displayName,
                                isSecure: false,
                                hasError: viewModel.isDisplayNameTooLong || viewModel.isDisplayNameInvalidFormat
                            )
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            
                            if viewModel.isDisplayNameTooLong {
                                Text("Too long. 15 max length")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else if viewModel.isDisplayNameInvalidFormat {
                                Text("Invalid characters. Only letters, numbers, and _ allowed")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else if let error = viewModel.displayNameError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        Spacer()
                        
                        // Account Actions Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Account Actions")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                // Sign Out Button
                                Button(action: { profileViewModel.signOut() }) {
                                    HStack {
                                        Text("Sign Out")
                                            .font(.system(size: 16, weight: .regular))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.clear)
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                // Delete Profile Button
                                Button {
                                    showingDeleteConfirmation = true
                                } label: {
                                    HStack {
                                        Text("Delete Profile")
                                            .font(.system(size: 16, weight: .regular))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.clear)
                                }
                                .alert("Confirm Deletion", isPresented: $showingDeleteConfirmation) {
                                    Button("Delete", role: .destructive) {
                                        Task {
                                            await profileViewModel.deleteProfile()
                                            dismiss()
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {}
                                } message: {
                                    Text("Are you sure you want to delete your profile? This action cannot be undone.")
                                }
                            }
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                    .tag(0)
                    
                    // Avatar Tab
                    EditAvatarView(userProfile: $userProfile, onAvatarChange: { avatarParts in
                        currentAvatarParts = avatarParts
                    })
                        .tag(1)
                        .onAppear {
                            // Initialize with current avatar parts
                            if let profile = userProfile {
                                currentAvatarParts = AvatarParts(
                                    background: profile.avatarBackground ?? "background_1",
                                    face: profile.avatarFace,
                                    eyes: profile.avatarEyes,
                                    mouth: profile.avatarMouth,
                                    hair: profile.avatarHair
                                )
                            }
                        }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { 
                        // Revert all changes by dismissing without saving
                        dismiss() 
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            var success = true
                            
                            // Always save profile information if there are changes
                            if let originalProfile = userProfile,
                               (viewModel.firstName != originalProfile.firstName || 
                                viewModel.displayName != originalProfile.displayName) {
                                success = await viewModel.saveChanges()
                                if success {
                                    // Push changes back into parent binding
                                    if var updated = userProfile {
                                        updated.firstName = viewModel.firstName
                                        updated.displayName = viewModel.displayName
                                        userProfile = updated
                                    }
                                }
                            }
                            
                            // Always save avatar changes regardless of current tab
                            // Get current avatar state from userProfile (which gets updated in real-time for preview)
                            if let profile = userProfile {
                                let avatarParts = AvatarParts(
                                    background: profile.avatarBackground ?? "background_1",
                                    face: profile.avatarFace,
                                    eyes: profile.avatarEyes,
                                    mouth: profile.avatarMouth,
                                    hair: profile.avatarHair
                                )
                                let avatarSuccess = await viewModel.saveAvatarChanges(avatarParts: avatarParts)
                                success = success && avatarSuccess
                            }
                            
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving || (selectedTab == 0 && !viewModel.isValid))
                }
            }
        }
    }
}
