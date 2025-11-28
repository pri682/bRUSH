import SwiftUI
import CoreImage
import UIKit

struct SignedInProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingEditProfile = false
    @State private var showingShareCard = false
    @State private var lastMedalUpdate: Date? = nil
    @State private var isRefreshingMedals = false
    @State private var lastRefreshAttempt: Date? = nil
    @State private var showRefreshToast = false
    @State private var profileBackgroundColor: Color = Color(UIColor.systemBackground)
    
    private static var colorCache: [String: Color] = [:]
    
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
        Date().timeIntervalSince(date) > 600
    }
    
    private func canRefresh() -> Bool {
        guard let lastAttempt = lastRefreshAttempt else { return true }
        return Date().timeIntervalSince(lastAttempt) > 60
    }
    
    private func refreshMedalData() {
        guard canRefresh() else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        lastRefreshAttempt = Date()
        isRefreshingMedals = true
        
        Task {
            await viewModel.refreshProfile()
            
            await MainActor.run {
                lastMedalUpdate = Date()
                isRefreshingMedals = false
                
                withAnimation(.spring()) {
                    showRefreshToast = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut) {
                        showRefreshToast = false
                    }
                }
            }
        }
    }
    
    private func updateBackgroundColor() {
        guard let profile = viewModel.profile,
              let bgName = profile.avatarBackground else { return }
        
        if let cachedColor = Self.colorCache[bgName] {
            self.profileBackgroundColor = cachedColor
            return
        }
        
        guard let image = UIImage(named: bgName) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let color = image.bottomEdgeColor {
                let swiftUIColor = Color(uiColor: color)
                DispatchQueue.main.async {
                    Self.colorCache[bgName] = swiftUIColor
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.profileBackgroundColor = swiftUIColor
                    }
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let safeAreaBottom = geometry.safeAreaInsets.bottom
            let standardPadding = screenWidth * 0.05
            
            let headerHeight = screenHeight * 0.30
            let containerTopSpacing = screenHeight * 0.06
            let maxAvailableHeight = screenHeight - headerHeight - containerTopSpacing/4 - safeAreaBottom
            let maxAvailableWidth = screenWidth
            
            let (finalCardWidth, finalCardHeight) = calculateCardDimensions(
                maxWidth: maxAvailableWidth,
                maxHeight: maxAvailableHeight
            )
            
            let largeMedalSize = finalCardWidth * 0.16
            
            let (avatarTextColor, avatarTextShadowColor): (Color, Color) = {
                if let background = viewModel.profile?.avatarBackground {
                    return ProfileElementsColorCalculation.calculateContrastingTextColor(for: background)
                }
                return (.white, .black)
            }()
            
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        profileBackgroundColor.opacity(0.3),
                        Color(UIColor.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .zIndex(0)
                
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
                            
                            if isProfileLoaded {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        VStack(spacing: isIpad ? 30 : 20) {
                                            Button { showingShareCard = true } label: {
                                                Image(systemName: "square.and.arrow.up")
                                                    .font(.system(size: isIpad ? 34 : 24, weight: .medium))
                                                    .foregroundColor(avatarTextColor)
                                            }
                                            
                                            Button { showingEditProfile = true } label: {
                                                Image(systemName: "gearshape")
                                                    .font(.system(size: isIpad ? 34 : 24, weight: .medium))
                                                    .foregroundColor(avatarTextColor)
                                            }
                                        }
                                        .padding(6)
                                        .glassEffect(.clear.tint(avatarTextShadowColor.opacity(0.05)).interactive())
                                    }
                                    .padding(.trailing, standardPadding * 0.40)
                                    .padding(.bottom, screenHeight * 0.02)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.profile?.firstName ?? "Placeholder Name")
                                    .font(.system(size: screenWidth * 0.08, weight: .bold))
                                    .foregroundColor(avatarTextColor)
                                    .shadow(color: avatarTextShadowColor, radius: 0, x: 0.9, y: 0.9)
                                
                                Text("@\(viewModel.profile?.displayName ?? "placeholder_username")")
                                    .font(.system(size: screenWidth * 0.03, weight: .semibold))
                                    .foregroundColor(
                                        avatarTextColor == .white
                                            ? Color(white: 0.85)
                                            : Color(white: 0.15)
                                    )
                            }
                            .padding(.leading, standardPadding * 0.55)
                            .padding(.bottom, screenHeight * 0.04)
                        }
                        .frame(height: headerHeight)
                        .padding(.bottom, containerTopSpacing)
                        
                        // Cards
                        VStack(spacing: 0) {
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
                            .frame(width: finalCardWidth, height: finalCardHeight)
                            .padding(.bottom, 30)
                            
                            Group {
                                if isRefreshingMedals {
                                    ProgressView()
                                        .scaleEffect(isIpad ? 1.0 : 0.8)
                                } else {
                                    let shouldShowButton = canRefresh() && (lastMedalUpdate == nil || needsUpdate(from: lastMedalUpdate!))
                                    
                                    if shouldShowButton {
                                        Button { refreshMedalData() } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: "arrow.clockwise")
                                                    .font(isIpad ? .system(size: 20) : .subheadline)
                                                
                                                Text(lastMedalUpdate != nil ? "Update Stats" : "Update Profile Stats")
                                            }
                                            .font(isIpad ? .system(size: 20) : .subheadline)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                        }
                                        .buttonStyle(.glass)
                                        .tint(.accentColor)
                                    } else {
                                        Group {
                                            if let lastUpdate = lastMedalUpdate {
                                                Text(needsUpdate(from: lastUpdate) ? "Please wait..." : "Last Updated \(timeDisplayString(from: lastUpdate))")
                                            } else {
                                                Text("Please wait...")
                                            }
                                        }
                                        .font(isIpad ? .system(size: 18) : .caption)
                                        .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .frame(width: screenWidth)
                    }
                    .frame(maxWidth: .infinity)
                    .redacted(reason: isProfileLoaded ? [] : .placeholder)
                    .disabled(!isProfileLoaded)
                }
                .scrollDisabled(true)
                .zIndex(1)
                
                if showRefreshToast {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Profile Updated")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassEffect(.regular)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
                }
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
        .onAppear { updateBackgroundColor() }
        .onChange(of: viewModel.profile?.avatarBackground) { updateBackgroundColor() }
    }
    
    private func calculateCardDimensions(maxWidth: CGFloat, maxHeight: CGFloat) -> (CGFloat, CGFloat) {
        let targetRatio: CGFloat = 1.25
        let heightFromWidth = maxWidth * targetRatio
        
        if heightFromWidth <= maxHeight {
            return (maxWidth, heightFromWidth)
        } else {
            return (maxHeight * 0.8, maxHeight)
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
            
            return effect.scaleEffect(x: scaleFactor, y: scaleFactor, anchor: .bottom)
        }
    }
}

extension UIImage {
    var bottomEdgeColor: UIColor? {
        let height = self.size.height
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: height * 0.05)
        
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: rect.origin.x, y: rect.origin.y, z: rect.size.width, w: rect.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
