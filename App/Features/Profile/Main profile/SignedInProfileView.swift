import SwiftUI

struct SignedInProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    @State private var lastMedalUpdate: Date? = nil
    @State private var isRefreshingMedals = false
    @State private var lastRefreshAttempt: Date? = nil
    
    private func timeDisplayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
    
    private func needsUpdate(from date: Date) -> Bool {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        return timeInterval > 600
    }
    
    private func canRefresh() -> Bool {
        guard let lastAttempt = lastRefreshAttempt else { return true }
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastAttempt)
        return timeInterval > 60
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

            let (avatarTextColor, avatarTextShadowColor): (Color, Color) = {
                if let background = viewModel.profile?.avatarBackground {
                    return ProfileElementsColorCalculation.calculateContrastingTextColor(for: background)
                }
                return (.white, .black)
            }()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
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
                                facialHair: profile.avatarFacialHair // CORRECTED: Now includes the new argument
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
                        
                        if viewModel.profile != nil {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button {
                                        showingEditProfile = true
                                    } label: {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 24, weight: .medium))
                                            // 💡 FIX: Use dynamic color for the gear icon
                                            .foregroundColor(avatarTextColor.opacity(0.85))
                                            // 💡 FIX: Use dynamic shadow color
                                            .shadow(color: avatarTextShadowColor, radius: 0, x: 1, y: 1)
                                        }
                                    .padding(.trailing, standardPadding * 0.75)
                                    .padding(.bottom, screenHeight * 0.02)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.profile?.firstName ?? "Loading...")
                                .font(.system(size: screenWidth * 0.08, weight: .bold))
                                .foregroundColor(avatarTextColor)
                                .shadow(color: avatarTextShadowColor, radius: 0, x: 0.9, y: 0.9)
                            
                            Text("@\(viewModel.profile?.displayName ?? "")")
                                .font(.system(size: screenWidth * 0.03, weight: .semibold))
                                .foregroundColor(avatarTextColor.opacity(0.85))
                        }
                        .padding(.leading, standardPadding * 0.55)
                        .padding(.bottom, screenHeight * 0.04)
                    }
                    .frame(height: headerHeight)
                    .padding(.bottom, containerTopSpacing)
                    
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
                        .animation(.easeInOut(duration: 0.4), value: isIpad)
                        
                        HStack {
                            Spacer()
                            Button {
                                refreshMedalData()
                            } label: {
                                HStack(spacing: 4) {
                                    if isRefreshingMedals {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(isIpad ? .system(size: 26) : .caption)
                                            .padding(.top, isIpad ? 200 : 8)
                                    }
                                    
                                    if let lastUpdate = lastMedalUpdate {
                                        if needsUpdate(from: lastUpdate) {
                                            if canRefresh() {
                                                Text("Last Updated \(timeDisplayString(from: lastUpdate)), Update now?")
                                                    .font(isIpad ? .system(size: 26) : .caption)
                                                    .padding(.top, isIpad ? 200 : 8)
                                            } else {
                                                Text("Last Updated \(timeDisplayString(from: lastUpdate)), Please wait...")
                                                    .font(isIpad ? .system(size: 26) : .caption)
                                                    .padding(.top, isIpad ? 200 : 8)
                                            }
                                        } else {
                                            Text("Last Updated \(timeDisplayString(from: lastUpdate))")
                                                .font(isIpad ? .system(size: 26) : .caption)
                                                .padding(.top, isIpad ? 200 : 8)
                                        }
                                    } else {
                                        if canRefresh() {
                                            Text("Update medal counts now?")
                                                .font(isIpad ? .system(size: 26) : .caption)
                                                .padding(.top, isIpad ? 200 : 8)
                                        } else {
                                            Text("Please wait before updating again...")
                                                .font(isIpad ? .system(size: 26) : .caption)
                                                .padding(.top, isIpad ? 200 : 8)
                                        }
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(canRefresh() ? .accent : .gray)
                            }
                            .disabled(isRefreshingMedals || !canRefresh())
                            Spacer()
                        }
                        .padding(.top, 8)
                        
                        Spacer(minLength: 100)
                    }
                            .padding(.top, isIpad ? -60 : 8)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top)
            .sheet(isPresented: $showingEditProfile) {
                if let _ = viewModel.profile {
                    EditProfileView(userProfile: $viewModel.profile, profileViewModel: viewModel)
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
