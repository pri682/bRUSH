import SwiftUI

struct EditProfileView: View {
    @Binding var userProfile: UserProfile?
    @ObservedObject var profileViewModel: ProfileViewModel
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingDeleteConfirmation = false
    
    // State to control the iPad modal sheet
    @State private var showingAvatarEditor = false
    
    @State private var currentAvatarParts: AvatarParts?
    @State private var originalAvatarParts: AvatarParts?

    init(userProfile: Binding<UserProfile?>, profileViewModel: ProfileViewModel) {
        self._userProfile = userProfile
        self.profileViewModel = profileViewModel
        _viewModel = StateObject(
            wrappedValue: EditProfileViewModel(userProfile: userProfile.wrappedValue!)
        )
        
        // Store original avatar state for cancel functionality
        if let profile = userProfile.wrappedValue {
            let avatarType = AvatarType(rawValue: profile.avatarType ?? "personal") ?? .personal
            _originalAvatarParts = State(initialValue: AvatarParts(
                avatarType: avatarType,
                background: profile.avatarBackground ?? "background_1",
                body: profile.avatarBody,
                shirt: profile.avatarShirt,
                eyes: profile.avatarEyes,
                mouth: profile.avatarMouth,
                hair: profile.avatarHair,
                facialHair: profile.avatarFacialHair
            ))
        }
    }

    var body: some View {
        // Check for device type
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        
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
                    VStack(alignment: .leading, spacing: 0) {
                        // First Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.headline)
                            // Using the InputField from your original file
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
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
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
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
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
                        .padding(.horizontal)
                        .padding(.top, 24)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .tag(0)
                    
                    // **CRITICAL FIX: Conditional Avatar Tab**
                    if isIpad {
                        // --- iPad LAYOUT ---
                        // Shows a button that presents a full-screen modal
                        VStack(spacing: 24) {
                            Spacer()
                            AvatarView(
                                avatarType: AvatarType(rawValue: userProfile?.avatarType ?? "personal") ?? .personal,
                                background: userProfile?.avatarBackground ?? "background_1",
                                avatarBody: userProfile?.avatarBody,
                                shirt: userProfile?.avatarShirt,
                                eyes: userProfile?.avatarEyes,
                                mouth: userProfile?.avatarMouth,
                                hair: userProfile?.avatarHair,
                                facialHair: userProfile?.avatarFacialHair
                            )
                            .frame(width: 200, height: 200)
                            .padding()
                            
                            Button {
                                showingAvatarEditor = true
                            } label: {
                                Text("Edit Avatar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.accentColor)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                        .tag(1)
                        
                    } else {
                        // --- iPhone LAYOUT ---
                        // Shows the editor inline, as you preferred
                        EditAvatarView(userProfile: $userProfile, onAvatarChange: { avatarParts in
                            currentAvatarParts = avatarParts
                        }, isPresentedModally: false) // Pass modal flag
                        .tag(1)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            // This modifier presents the full-screen cover *only* on iPad
            .fullScreenCover(isPresented: $showingAvatarEditor) {
                EditAvatarView(userProfile: $userProfile, onAvatarChange: { avatarParts in
                    currentAvatarParts = avatarParts
                }, isPresentedModally: true) // Pass modal flag
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        // Revert avatar changes to original state
                        if let original = originalAvatarParts, var profile = userProfile {
                            profile.avatarType = original.avatarType.rawValue
                            profile.avatarBackground = original.background
                            profile.avatarBody = original.body
                            profile.avatarShirt = original.shirt
                            profile.avatarEyes = original.eyes
                            profile.avatarMouth = original.mouth
                            profile.avatarHair = original.hair
                            profile.avatarFacialHair = original.facialHair
                            userProfile = profile
                        }
                        
                        // Revert profile information changes to original state
                        if let originalProfile = profileViewModel.profile {
                            viewModel.firstName = originalProfile.firstName
                            viewModel.displayName = originalProfile.displayName
                        }
                        
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
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
                            if let profile = userProfile {
                                let avatarParts = AvatarParts(
                                    avatarType: AvatarType(rawValue: profile.avatarType ?? "personal") ?? .personal,
                                    background: profile.avatarBackground ?? "background_1",
                                    body: profile.avatarBody,
                                    shirt: profile.avatarShirt,
                                    eyes: profile.avatarEyes,
                                    mouth: profile.avatarMouth,
                                    hair: profile.avatarHair,
                                    facialHair: profile.avatarFacialHair
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
