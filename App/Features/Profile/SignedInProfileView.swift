import SwiftUI

struct SignedInProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            let standardPadding = screenWidth * 0.05
            let contentWidth = screenWidth - (standardPadding * 2)
            
            let headerHeight = screenHeight * 0.30 // Increased height for more background
            let containerTopSpacing = screenHeight * 0.08 // More spacing from top
            let cardHeight: CGFloat = screenHeight * 0.52 // ⬆ slightly taller visually
            
            let largeMedalSize = contentWidth * 0.16
            let cardStackHorizontalPadding = screenWidth * 0.10
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: Header
                    ZStack(alignment: .bottomLeading) {
                        // Use custom avatar if available, otherwise use default "boko" image
                        if let profile = viewModel.profile,
                           let background = profile.avatarBackground {
                            AvatarView(
                                background: background,
                                face: profile.avatarFace,
                                eyes: profile.avatarEyes,
                                mouth: profile.avatarMouth,
                                hair: profile.avatarHair
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: headerHeight + 40)
                            .clipped()
//                            .brightness(0.0005)
//                            .saturation(1)
                            .clipShape(RoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight]))
                        } else {
                            Image("boko")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: headerHeight + 40)
//                                .brightness(-0.01)
//                                .saturation(1)
                                .clipShape(RoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight]))
                        }
                        
                        // Pencil button in bottom right
                        if viewModel.profile != nil {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button {
                                        showingEditProfile = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.white)
                                            .shadow(color: .black, radius: 0, x: 1, y: 1)
                                    }
                                    .padding(.trailing, standardPadding * 0.75)
                                    .padding(.bottom, screenHeight * 0.02)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.profile?.firstName ?? "Loading...")
                                .font(.system(size: screenWidth * 0.08, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 0, x: 0.9, y: 0.9)
                            
                            Text("@\(viewModel.profile?.displayName ?? "")")
                                .font(.system(size: screenWidth * 0.03, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.leading, standardPadding * 0.55)
                        .padding(.bottom, screenHeight * 0.04)
                    }
                    .frame(height: headerHeight)
                    .padding(.bottom, containerTopSpacing)
                    
                    // MARK: - Awards Stack
                    VStack(spacing: screenHeight * 0.03) {
                        CardStackView(cards: [
                            CardItem(content:
                                AwardsStackCardView(
                                    cardTypeTitle: "Awards Received",
                                    firstPlaceCount: 128,
                                    secondPlaceCount: 421,
                                    thirdPlaceCount: 67,
                                    medalIconSize: largeMedalSize
                                )
                            ),
                            CardItem(content:
                                AwardsStackCardView(
                                    cardTypeTitle: "Awards Given",
                                    firstPlaceCount: 45,
                                    secondPlaceCount: 110,
                                    thirdPlaceCount: 20,
                                    medalIconSize: largeMedalSize
                                )
                            )
                        ])
                        .frame(height: cardHeight)
                        .padding(.horizontal, cardStackHorizontalPadding)
                        .padding(.top, isIpad ? 60 : 40) // ✅ gives more space below header
                        .scaleEffect(isIpad ? 1.12 : 1.05) // ✅ slightly bigger visually
                        .animation(.easeInOut(duration: 0.4), value: isIpad)
                        
                        Spacer(minLength: 100)
                        
                        // MARK: - Sign Out / Delete
                        Button(action: { viewModel.signOut() }) {
                            HStack {
                                Text("Sign Out").font(.headline)
                                Spacer()
                                Image(systemName: "arrow.right.square.fill").font(.title2)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.8), lineWidth: 1.5)
                            )
                        }
                        .padding(.horizontal, standardPadding)
                        
                        DeleteProfileButton(viewModel: viewModel)
                            .padding(.horizontal, standardPadding)
                    }
                    .padding(.bottom, screenHeight * 0.03)
                }
                .frame(maxWidth: .infinity)
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
}
