import SwiftUI

/**
 * FriendProfileView - A read-only profile view for displaying friend information
 * 
 * This view displays a friend's profile information in a full-screen layout similar to
 * the user's own SignedInProfileView, but without any editing capabilities (no settings gear,
 * no update medal count button). It shows the friend's avatar, name, username, and all
 * their statistics (medals, awards, streak) in a read-only format.
 */
struct FriendProfileView: View {
    // MARK: - Properties
    
    /// The unique identifier of the friend whose profile we're displaying
    let friendUid: String
    
    /// ViewModel that handles loading and managing the friend's profile data
    @StateObject private var viewModel = FriendProfileViewModel()
    
    /// Environment value that allows us to dismiss this view (go back to friends list)
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        // GeometryReader gives us access to screen dimensions for responsive layout
        GeometryReader { geometry in
            
            // MARK: - Layout Calculations
            // Calculate responsive dimensions based on screen size
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Standard padding used throughout the app (5% of screen width)
            let standardPadding = screenWidth * 0.05
            let contentWidth = screenWidth - (standardPadding * 2)
            
            // Header takes up 30% of screen height for avatar background
            let headerHeight = screenHeight * 0.30
            // Spacing between header and main content
            let containerTopSpacing = screenHeight * 0.08
            // Cards take up 52% of screen height
            let cardHeight: CGFloat = screenHeight * 0.52
            
            // Medal icons are sized relative to content width
            let largeMedalSize = contentWidth * 0.16
            // Horizontal padding for card stack
            let cardStackHorizontalPadding = screenWidth * 0.10
            // Check if device is iPad for responsive adjustments
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            
            // MARK: - Loading State
            // Show loading spinner while fetching friend's profile data
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5) // Make loading spinner larger
                    Text("Loading profile...")
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                
            // MARK: - Error State
            // Show error message if profile loading failed
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
                            // Retry loading the friend's profile
                            await viewModel.loadFriendProfile(uid: friendUid)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                
            // MARK: - Profile Content
            // Display the friend's profile information
            } else if let profile = viewModel.profile {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: - Header Section
                        // ZStack allows us to overlay text on top of the avatar image
                        ZStack(alignment: .bottomLeading) {
                            
                            // MARK: - Avatar Background
                            // Display custom avatar if friend has one, otherwise use default "boko" image
                            if let background = profile.avatarBackground {
                                // Custom avatar with all the avatar components (background, face, eyes, mouth, hair)
                                AvatarView(
                                    background: background,
                                    face: profile.avatarFace,
                                    eyes: profile.avatarEyes,
                                    mouth: profile.avatarMouth,
                                    hair: profile.avatarHair
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: headerHeight + 40) // Extra height for better visual impact
                                .clipped() // Ensure image doesn't overflow
                                .clipShape(RoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight]))
                            } else {
                                // Fallback to default "boko" image if no custom avatar
                                Image("boko")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: headerHeight + 40)
                                    .clipped()
                                    .clipShape(RoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight]))
                            }
                            
                            // MARK: - Profile Info Overlay
                            // Display friend's name and username overlaid on the avatar image
                            VStack(alignment: .leading, spacing: 8) {
                                // Friend's display name in large, bold white text
                                Text(profile.displayName)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                
                                // Friend's username with @ symbol
                                Text("@\(profile.displayName)")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                            }
                            .padding(.leading, standardPadding)
                            .padding(.bottom, 20)
                        }
                        
                        // MARK: - Main Content Section
                        VStack(spacing: 0) {
                            // MARK: - Card Stack Container
                            // Display friend's statistics in a stack of cards
                            VStack(spacing: 0) {
                                CardStackView(cards: [
                                    // First card: Awards Accumulated (medals the friend has earned)
                                    CardItem(content: AnyView(
                                        AwardsStackCardView(
                                            cardTypeTitle: "Awards Accumulated",
                                            firstPlaceCount: profile.goldMedalsAccumulated,
                                            secondPlaceCount: profile.silverMedalsAccumulated,
                                            thirdPlaceCount: profile.bronzeMedalsAccumulated,
                                            medalIconSize: largeMedalSize
                                        )
                                    )),
                                    // Second card: Awards Awarded to Friends (medals the friend has given to others)
                                    CardItem(content: AnyView(
                                        AwardsStackCardView(
                                            cardTypeTitle: "Awarded to Friends",
                                            firstPlaceCount: profile.goldMedalsAwarded,
                                            secondPlaceCount: profile.silverMedalsAwarded,
                                            thirdPlaceCount: profile.bronzeMedalsAwarded,
                                            medalIconSize: largeMedalSize
                                        )
                                    )),
                                    // Third card: Streak information (current streak and total drawings)
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
                            
                            // MARK: - Back Button
                            // Simple button to return to the friends list
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
                            
                            // Bottom spacing to ensure content doesn't get cut off
                            Spacer(minLength: 100)
                        }
                        .padding(.bottom, screenHeight * 0.03)
                    }
                    .frame(maxWidth: .infinity)
                }
                // Hide the navigation bar since we have our own back button
                .navigationBarHidden(true)
                // Extend content to the top of the screen (behind status bar)
                .edgesIgnoringSafeArea(.top)
            }
        }
        // MARK: - Lifecycle
        // Load the friend's profile data when this view appears
        .onAppear {
            Task {
                await viewModel.loadFriendProfile(uid: friendUid)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FriendProfileView(friendUid: "preview_uid")
}