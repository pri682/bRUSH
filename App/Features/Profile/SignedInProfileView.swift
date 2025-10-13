import SwiftUI

struct SignedInProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    
    // Header height
    @State private var headerHeight: CGFloat = UIScreen.main.bounds.height * 0.30
    let containerTopSpacing: CGFloat = 30

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                
                // MARK: - Profile Header
                ZStack(alignment: .bottomLeading) {
                    Image("boko") // Replace with dynamic profile image if needed
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: headerHeight + 40)
                        .overlay(Color.black.opacity(0.2))
                        .clipShape(RoundedCorners(radius: 40, corners: [.bottomLeft, .bottomRight]))
                        .clipped()

                    VStack(alignment: .leading, spacing: 6) {
                        // Name + Pencil Button
                        HStack(spacing: 8) {
                            Text(viewModel.profile?.firstName ?? "Loading...")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)

                            // System pencil icon
                            if viewModel.profile != nil {
                                Button {
                                    showingEditProfile = true
                                } label: {
                                    Image(systemName: "pencil") // system pencil
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.black.opacity(0.4))
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                            }
                        }

                        // Username
                        Text("@\(viewModel.profile?.displayName ?? "")")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.leading, 30)
                    .padding(.bottom, 40)

                }
                .frame(height: headerHeight)
                .frame(maxWidth: .infinity)
                .padding(.bottom, containerTopSpacing)
                
                VStack(spacing: 24) {
                    
                    // MARK: - Awards Container
                    GradientOutlineBox(
                        title: "Awards",
                        gradient: LinearGradient(
                            gradient: Gradient(colors: [Color.pink, Color.orange, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) {
                        HStack(alignment: .top) {
                            MedalView(imageName: "gold_medal", count: 0, medalSize: 75, textSize: .subheadline)
                            Spacer()
                            MedalView(imageName: "silver_medal", count: 0, medalSize: 75, textSize: .subheadline)
                            Spacer()
                            MedalView(imageName: "bronze_medal", count: 0, medalSize: 75, textSize: .subheadline)
                            Spacer()
                            MedalView(imageName: "participation_medal", count: 0, medalSize: 75, textSize: .subheadline)
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.horizontal, 40)
                    
                    // MARK: - Awards Given + Streak
                    HStack(alignment: .top, spacing: 16) {
                        GradientOutlineBox(
                            title: "Awards Given",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.pink]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        ) {
                            HStack(alignment: .top, spacing: 12) {
                                MedalView(imageName: "gold_medal", count: 0, medalSize: 50, textSize: .footnote)
                                MedalView(imageName: "silver_medal", count: 0, medalSize: 50, textSize: .footnote)
                                MedalView(imageName: "bronze_medal", count: 0, medalSize: 50, textSize: .footnote)
                                MedalView(imageName: "participation_medal", count: 0, medalSize: 50, textSize: .footnote)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        StreakBox(
                            streakCount: 378, // Replace with dynamic streak
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    .padding(.horizontal, 40)
                    
                    // MARK: - Sign Out Button
                    Button(action: { viewModel.signOut() }) {
                        HStack {
                            Text("Sign Out")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "arrow.right.square.fill")
                                .font(.title2)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.8), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 40)
                    
                    // MARK: - Delete Profile Button
                    DeleteProfileButton(viewModel: viewModel)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingEditProfile) {
            if let _ = viewModel.profile {
                EditProfileView(userProfile: $viewModel.profile)
            }
        }
    }
}
