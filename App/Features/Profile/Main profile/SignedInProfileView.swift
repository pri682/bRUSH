import SwiftUI

struct SignedInProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    @State private var showingShareCard = false
    @State private var lastMedalUpdate: Date? = nil
    @State private var isRefreshingMedals = false
    @State private var lastRefreshAttempt: Date? = nil
    
    private var isProfileLoaded: Bool {
        viewModel.profile != nil
    }
    
    private func timeDisplayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
    
    private func needsUpdate(from date: Date) -> Bool {
        let now = Date()
        return now.timeIntervalSince(date) > 600
    }
    
    private func canRefresh() -> Bool {
        guard let lastAttempt = lastRefreshAttempt else { return true }
        return Date().timeIntervalSince(lastAttempt) > 60
    }
    
    private func refreshMedalData() {
        guard canRefresh() else { return }
        
        lastRefreshAttempt = Date()
        isRefreshingMedals = true
        Task {
            await viewModel.refreshProfile()
            lastMedalUpdate = Date()
            isRefreshingMedals = false
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            let standardPadding = screenWidth * 0.05
            let contentWidth = screenWidth - (standardPadding * 2)
            
            let headerHeight = screenHeight * 0.30
            let containerTopSpacing = screenHeight * 0.08
            let cardHeight: CGFloat = screenHeight * 0.52
            
            let largeMedalSize = contentWidth * 0.16
            let cardStackHorizontalPadding = screenWidth * 0.10
            
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            
            // Dynamic color for avatar text
            let (avatarTextColor, avatarTextShadowColor): (Color, Color) = {
                if let background = viewModel.profile?.avatarBackground {
                    return ProfileElementsColorCalculation.calculateContrastingTextColor(for: background)
                }
                return (.white, .black)
            }()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: Header
                    ZStack(alignment: .bottomLeading) {
                        
                        // Avatar Background (stretchy)
                        if let profile = viewModel.profile,
                           let background = profile.avatarBackground {
                            
                            AvatarView(
                                avatarType: AvatarType(rawValue: profile.avatarType ?? "personal") ?? .personal,
                                background: background,
                                avatarBody: profile.avatarBody,
                                shirt: profile.avatarShirt,
                                eyes: profile.avatarEyes,
                                mouth: profile.avatarMouth,
                                hair: profile.avatarHair,
                                facialHair: profile.avatarFacialHair
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: headerHeight + 40)
                            .clipped()
                            .stretchy()
                            
                        } else {
                            Image("profile_loading")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: headerHeight + 40)
                                .clipped()
                                .stretchy()
                        }
                        
                        // 📌 BUTTON STACK (Share + Gear)
                        if isProfileLoaded {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    
                                    VStack(spacing: isIpad ? 30 : 20) {
                                        
                                        // Share
                                        Button {
                                            showingShareCard = true
                                        } label: {
                                            Image(systemName: "square.and.arrow.up.fill")
                                                .font(.system(size: isIpad ? 34 : 24, weight: .medium))
                                                .foregroundColor(avatarTextColor.opacity(0.85))
                                                .shadow(color: avatarTextShadowColor, radius: 0, x: 1, y: 1)
                                        }
                                        
                                        // Gear
                                        Button {
                                            showingEditProfile = true
                                        } label: {
                                            Image(systemName: "gearshape.fill")
                                                .font(.system(size: isIpad ? 34 : 24, weight: .medium))
                                                .foregroundColor(avatarTextColor.opacity(0.85))
                                                .shadow(color: avatarTextShadowColor, radius: 0, x: 1, y: 1)
                                        }
                                    }
                                    .padding(.trailing, standardPadding * 0.75)
                                    .padding(.bottom, screenHeight * 0.02)
                                }
                            }
                        }
                        
                        // Name + Username
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.profile?.firstName ?? "Placeholder Name")
                                .font(.system(size: screenWidth * 0.08, weight: .bold))
                                .foregroundColor(avatarTextColor)
                                .shadow(color: avatarTextShadowColor, radius: 0, x: 0.9, y: 0.9)
                            
                            Text("@\(viewModel.profile?.displayName ?? "placeholder_username")")
                                .font(.system(size: screenWidth * 0.03, weight: .semibold))
                                .foregroundColor(avatarTextColor.opacity(0.85))
                        }
                        .padding(.leading, standardPadding * 0.55)
                        .padding(.bottom, screenHeight * 0.04)
                    }
                    .frame(height: headerHeight)
                    .padding(.bottom, containerTopSpacing)
                    
                    
                    // MARK: Cards
                    VStack(spacing: screenHeight * 0.03) {
                        
                        CardStackView(cards: [
                            CardItem(content: AnyView(
                                AwardsStackCardView(
                                    cardTypeTitle: "Awards Accumulated",
                                    firstPlaceCount: viewModel.profile?.goldMedalsAccumulated ?? 0,
                                    secondPlaceCount: viewModel.profile?.silverMedalsAccumulated ?? 0,
                                    thirdPlaceCount: viewModel.profile?.bronzeMedalsAccumulated ?? 0,
                                    medalIconSize: largeMedalSize
                                )
                            )),
                            
                            CardItem(content: AnyView(
                                AwardsStackCardView(
                                    cardTypeTitle: "Awarded to Friends",
                                    firstPlaceCount: viewModel.profile?.goldMedalsAwarded ?? 0,
                                    secondPlaceCount: viewModel.profile?.silverMedalsAwarded ?? 0,
                                    thirdPlaceCount: viewModel.profile?.bronzeMedalsAwarded ?? 0,
                                    medalIconSize: largeMedalSize
                                )
                            )),
                            
                            CardItem(content: AnyView(
                                StreakCardView(
                                    streakCount: viewModel.profile?.streakCount ?? 0,
                                    totalDrawings: viewModel.profile?.totalDrawingCount ?? 0,
                                    memberSince: viewModel.profile?.memberSince ?? Date(),
                                    iconSize: largeMedalSize
                                )
                            ))
                        ])
                        .frame(height: cardHeight)
                        .padding(.horizontal, cardStackHorizontalPadding)
                        .padding(.top, isIpad ? 60 : 40)
                        .scaleEffect(isIpad ? 1.12 : 1.05)
                        .animation(.easeInOut(duration: 0.4), value: isIpad)
                        
                        
                        // MARK: Refresh Button (iPad-aware)
                        HStack {
                            Spacer()
                            Button {
                                refreshMedalData()
                            } label: {
                                HStack(spacing: 4) {
                                    
                                    if isRefreshingMedals {
                                        ProgressView()
                                            .scaleEffect(isIpad ? 1.0 : 0.7)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(isIpad ? .system(size: 26) : .caption)
                                            .padding(.top, isIpad ? 200 : 8)
                                    }
                                    
                                    // Text
                                    Group {
                                        if let lastUpdate = lastMedalUpdate {
                                            if needsUpdate(from: lastUpdate) {
                                                if canRefresh() {
                                                    Text("Last Updated \(timeDisplayString(from: lastUpdate)), Update now?")
                                                } else {
                                                    Text("Last Updated \(timeDisplayString(from: lastUpdate)), Please wait...")
                                                }
                                            } else {
                                                Text("Last Updated \(timeDisplayString(from: lastUpdate))")
                                            }
                                        } else {
                                            if canRefresh() {
                                                Text("Update medal counts now?")
                                            } else {
                                                Text("Please wait before updating again...")
                                            }
                                        }
                                    }
                                    .font(isIpad ? .system(size: 26) : .caption)
                                    .padding(.top, isIpad ? 200 : 8)
                                    
                                }
                                .foregroundColor(canRefresh() ? .accentColor : .gray)
                            }
                            .disabled(isRefreshingMedals || !canRefresh())
                            Spacer()
                        }
                        .padding(.top, 8)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, screenHeight * 0.03)
                }
                .frame(maxWidth: .infinity)
                .redacted(reason: isProfileLoaded ? [] : .placeholder)
                .disabled(!isProfileLoaded)
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top)
            
            // Edit Profile
            .sheet(isPresented: $showingEditProfile) {
                if let _ = viewModel.profile {
                    EditProfileView(userProfile: $viewModel.profile, profileViewModel: viewModel)
                }
            }
            
            // Share Card
            .sheet(isPresented: $showingShareCard) {
                if let profile = viewModel.profile {
                    ShareCardGeneratorView(userProfile: profile)
                }
            }
        }
    }
}


extension View {
    func stretchy() -> some View {
        visualEffect { effect, geometry in
            let currentHeight = geometry.size.height
            let scrollOffset = geometry.frame(in: .scrollView).minY
            let positiveOffset = max(0, scrollOffset)
            
            let newHeight = currentHeight + positiveOffset
            let scaleFactor = newHeight / currentHeight
            
            return effect.scaleEffect(
                x: scaleFactor, y: scaleFactor,
                anchor: .bottom
            )
        }
    }
}
