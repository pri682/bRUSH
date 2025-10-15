import SwiftUI

struct SignedInProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let responsivePadding = screenWidth * 0.05
            let headerHeight = screenHeight * 0.32
            let containerTopSpacing = screenHeight * 0.05
            let contentWidth = screenWidth - (responsivePadding * 2)
            let largeMedalSize = contentWidth * 0.18
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - Profile Header
                    ZStack(alignment: .bottomLeading) {
                        Image("boko")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: headerHeight + 40)
                            .overlay(Color.black.opacity(0.25))
                            .clipShape(RoundedCorners(radius: 20, corners: [.bottomLeft, .bottomRight]))
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text(viewModel.profile?.firstName ?? "Loading...")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                
                                if viewModel.profile != nil {
                                    Button {
                                        showingEditProfile = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.black.opacity(0.4))
                                            .clipShape(Circle())
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                            
                            Text("@\(viewModel.profile?.displayName ?? "")")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.leading, responsivePadding * 0.75)
                        .padding(.bottom, screenHeight * 0.04)
                    }
                    .frame(height: headerHeight)
                    .padding(.bottom, containerTopSpacing)
                    
                    VStack(spacing: screenHeight * 0.03) {
                        
                        // MARK: - Swipable Awards Stack (Animated)
                        CardStackView(cards: [
                            CardItem(content:
                                AwardsCardView(
                                    title: "Awards Received",
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [Color.pink, Color.orange, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    largeMedalSize: largeMedalSize
                                )
                            ),
                            CardItem(content:
                                AwardsCardView(
                                    title: "Awards Given",
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.pink]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    largeMedalSize: largeMedalSize
                                )
                            )
                        ])
                        .frame(height: largeMedalSize * 2.5)
                        .padding(.horizontal, responsivePadding)
                        .padding(.top, 5)
                        
                        // MARK: - Sign Out
                        Button(action: {
                            viewModel.signOut()
                        }) {
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
                        .padding(.horizontal, responsivePadding)
                        
                        // MARK: - Delete Profile
                        DeleteProfileButton(viewModel: viewModel)
                            .padding(.horizontal, responsivePadding)
                    }
                    .padding(.bottom, screenHeight * 0.03)
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
}

// MARK: - AwardsCardView (shared between Received/Given)
struct AwardsCardView: View {
    let title: String
    let gradient: LinearGradient
    let largeMedalSize: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline.bold())
                .foregroundColor(.primary)
            
            HStack(alignment: .top, spacing: 0) {
                MedalView(imageName: "gold_medal", count: 0, medalSize: largeMedalSize, textSize: .subheadline)
                Spacer(minLength: 0)
                MedalView(imageName: "silver_medal", count: 0, medalSize: largeMedalSize, textSize: .subheadline)
                Spacer(minLength: 0)
                MedalView(imageName: "bronze_medal", count: 0, medalSize: largeMedalSize, textSize: .subheadline)
                Spacer(minLength: 0)
                MedalView(imageName: "participation_medal", count: 0, medalSize: largeMedalSize, textSize: .subheadline)
            }
            .padding(.horizontal, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(gradient, lineWidth: 2)
                )
        )
    }
}
