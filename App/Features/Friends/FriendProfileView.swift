import SwiftUI

struct FriendProfileView: View {
    let friendUid: String
    @StateObject private var viewModel = FriendProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
            
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading profile...")
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Failed to load profile")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task {
                            await viewModel.loadFriendProfile(uid: friendUid)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else if let profile = viewModel.profile {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: Header
                        ZStack(alignment: .bottomLeading) {
                            // Use custom avatar if available, otherwise use default "boko" image
                            if let background = profile.avatarBackground {
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
                                .clipShape(RoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight]))
                            } else {
                                Image("boko")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: headerHeight + 40)
                                    .clipped()
                                    .clipShape(RoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight]))
                            }
                            
                            // Profile info overlay
                            VStack(alignment: .leading, spacing: 8) {
                                Text(profile.displayName)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                
                                Text("@\(profile.displayName)")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                            }
                            .padding(.leading, standardPadding)
                            .padding(.bottom, 20)
                        }
                        
                        // MARK: Main Content
                        VStack(spacing: 0) {
                            // Card Stack Container
                            VStack(spacing: 0) {
                                CardStackView(cards: [
                                    CardItem(content: AnyView(
                                        AwardsStackCardView(
                                            cardTypeTitle: "Awards Accumulated",
                                            firstPlaceCount: profile.goldMedalsAccumulated,
                                            secondPlaceCount: profile.silverMedalsAccumulated,
                                            thirdPlaceCount: profile.bronzeMedalsAccumulated,
                                            medalIconSize: largeMedalSize
                                        )
                                    )),
                                    CardItem(content: AnyView(
                                        AwardsStackCardView(
                                            cardTypeTitle: "Awarded to Friends",
                                            firstPlaceCount: profile.goldMedalsAwarded,
                                            secondPlaceCount: profile.silverMedalsAwarded,
                                            thirdPlaceCount: profile.bronzeMedalsAwarded,
                                            medalIconSize: largeMedalSize
                                        )
                                    )),
                                    CardItem(content: AnyView(
                                        StreakCardView(
                                            streakCount: profile.streakCount,
                                            totalDrawings: profile.totalDrawingCount,
                                            memberSince: profile.memberSince,
                                            iconSize: largeMedalSize
                                        )
                                    ))
                                ])
                                .frame(height: cardHeight)
                                .padding(.horizontal, cardStackHorizontalPadding)
                            }
                            .padding(.top, containerTopSpacing)
                            
                            // Simple back button
                            Button(action: { dismiss() }) {
                                Text("Back to Friends View")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(Color.blue)
                                    .cornerRadius(25)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .padding(.top, 30)
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.bottom, screenHeight * 0.03)
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.top)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadFriendProfile(uid: friendUid)
            }
        }
    }
    
}

#Preview {
    FriendProfileView(friendUid: "preview_uid")
}
