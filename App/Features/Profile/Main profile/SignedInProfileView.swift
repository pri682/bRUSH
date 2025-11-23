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
        return now.timeIntervalSince(date) > 600 // 10m
    }
    
    private func canRefresh() -> Bool {
        guard let lastAttempt = lastRefreshAttempt else { return true }
        return Date().timeIntervalSince(lastAttempt) > 60 // 1m cooldown
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
            let cardHeight = screenHeight * 0.52
            
            let largeMedalSize = contentWidth * 0.16
            let cardStackHorizontalPadding = screenWidth * 0.10
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            
            let (avatarTextColor, avatarTextShadowColor): (Color, Color) = {
                if let bg = viewModel.profile?.avatarBackground {
                    return ProfileElementsColorCalculation.calculateContrastingTextColor(for: bg)
                }
                return (.white, .black)
            }()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: HEADER
                    ZStack(alignment: .bottomLeading) {
                        
                        // Background avatar or fallback
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
                            Image("boko")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: headerHeight + 40)
                                .clipped()
                                .stretchy()
                        }
                        
                        // MARK: Top Buttons
                        if viewModel.profile != nil {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    
                                    VStack(spacing: 20) {
                                        
                                        // Share button
                                        Button {
                                            showingShareCard = true
                                        } label: {
                                            Image(systemName: "square.and.arrow.up.fill")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundColor(avatarTextColor.opacity(0.85))
                                                .shadow(color: avatarTextShadowColor, radius: 0, x: 1, y: 1)
                                        }
                                        
                                        // Gear button
                                        Button {
                                            showingEditProfile = true
                                        } label: {
                                            Image(systemName: "gearshape.fill")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundColor(avatarTextColor.opacity(0.85))
                                                .shadow(color: avatarTextShadowColor, radius: 0, x: 1, y: 1)
                                        }
                                    }
                                    .padding(.trailing, standardPadding * 0.75)
                                    .padding(.bottom, screenHeight * 0.02)
                                }
                            }
                            
                            // MARK: Name + Username
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.profile?.firstName ?? "Placeholder")
                                    .font(.system(size: screenWidth * 0.08, weight: .bold))
                                    .foregroundColor(avatarTextColor)
                                    .shadow(color: avatarTextShadowColor, radius: 0, x: 0.9, y: 0.9)
                                
                                Text("@\(viewModel.profile?.displayName ?? "placeholder")")
                                    .font(.system(size: screenWidth * 0.03, weight: .semibold))
                                    .foregroundColor(avatarTextColor.opacity(0.85))
                            }
                            .padding(.leading, standardPadding * 0.55)
                            .padding(.bottom, screenHeight * 0.04)
                        }
                        
                    }
                    .frame(height: headerHeight)
                    .padding(.bottom, containerTopSpacing * 0.5)
                    
                    
                    // MARK: Card Stack + Refresh Area
                    VStack(spacing: screenHeight * 0.03) {
                        
                        CardStackView(cards: [
                            CardItem(content: AnyView(
                                AwardsStackCardView(
                                    cardTypeTitle: "Awards Accumulated",
                                    firstPlaceCount: viewModel.profile?.goldMedalsAccumulated ?? -1,
                                    secondPlaceCount: viewModel.profile?.silverMedalsAccumulated ?? -1,
                                    thirdPlaceCount: viewModel.profile?.bronzeMedalsAccumulated ?? -1,
                                    medalIconSize: largeMedalSize,
                                    isCurrentUser: true
                                )
                            )),
                            
                            CardItem(content: AnyView(
                                AwardsStackCardView(
                                    cardTypeTitle: "Awarded to Friends",
                                    firstPlaceCount: viewModel.profile?.goldMedalsAwarded ?? -1,
                                    secondPlaceCount: viewModel.profile?.silverMedalsAwarded ?? -1,
                                    thirdPlaceCount: viewModel.profile?.bronzeMedalsAwarded ?? -1,
                                    medalIconSize: largeMedalSize,
                                    isCurrentUser: true
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
                        
                        
                        // MARK: Last Updated + Refresh
                        HStack {
                            Spacer()
                            Button {
                                refreshMedalData()
                            } label: {
                                HStack(spacing: 4) {
                                    
                                    if isRefreshingMedals {
                                        ProgressView().scaleEffect(0.7)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(isIpad ? .system(size: 26) : .caption)
                                    }
                                    
                                    if let last = lastMedalUpdate {
                                        if needsUpdate(from: last) {
                                            Text(canRefresh()
                                                 ? "Last Updated \(timeDisplayString(from: last)), Update now?"
                                                 : "Last Updated \(timeDisplayString(from: last)), Please wait..."
                                            )
                                        } else {
                                            Text("Last Updated \(timeDisplayString(from: last))")
                                        }
                                    } else {
                                        Text(canRefresh()
                                             ? "Update medal counts now?"
                                             : "Please wait before updating again..."
                                        )
                                    }
                                }
                                .font(isIpad ? .system(size: 26) : .caption)
                                .padding(.top, isIpad ? 200 : 8)
                                .foregroundColor(canRefresh() ? .accentColor : .gray)
                            }
                            .disabled(isRefreshingMedals || !canRefresh())
                            Spacer()
                        }
                        .padding(.top, 8)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, isIpad ? -60 : 8)
                    .padding(.bottom, 20)
                    .background(
                        Color.accentColor.opacity(0.15)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    )
                }
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.top)
                .sheet(isPresented: $showingEditProfile) {
                    if let _ = viewModel.profile {
                        EditProfileView(userProfile: $viewModel.profile, profileViewModel: viewModel)
                    }
                }
                .sheet(isPresented: $showingShareCard) {
                    if let profile = viewModel.profile {
                        ShareCardGeneratorView(userProfile: profile)
                    }
                }
            }
        }
    }
}

//
// MARK: - Stretchy Header Modifier
//
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
