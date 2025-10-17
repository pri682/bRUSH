import SwiftUI

struct StreakCardView: View {
    let streakCount: Int
    let totalDrawings: Int
    let memberSince: String
    let iconSize: CGFloat

    // Base icon scale
    private let baseIconScaleFactor: CGFloat = 1.8

    // Colors
    private let streakColor = Color(hex: "#ff6b35")! // Orange
    private let streakBackgroundStart = Color(hex: "#ffe8e0")!
    private let streakBackgroundEnd = Color(hex: "#ffb399")!
    
    private let drawingsColor = Color(hex: "#4a90e2")! // Blue
    private let drawingsBackgroundStart = Color(hex: "#e3f2fd")!
    private let drawingsBackgroundEnd = Color(hex: "#90caf9")!
    
    private let memberColor = Color(hex: "#9c27b0")! // Purple
    private let memberBackgroundStart = Color(hex: "#f3e5f5")!
    private let memberBackgroundEnd = Color(hex: "#ce93d8")!

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let cardHeight = geometry.size.height
            let rowHeight = cardHeight / 3
            
            // Device / size detection
            let isPad = UIDevice.current.userInterfaceIdiom == .pad || cardWidth > 600
            
            let rowHeightAdjusted = rowHeight * (isPad ? 1.2 : 1.0)  // Give more height on iPad
            let radius = min(cardWidth, cardHeight) * 0.06

            // Font & icon scaling
            let fontFactorBase = cardWidth / 400
            let fontFactor = fontFactorBase * (isPad ? 0.75 : 1.0)  // More conservative iPad scaling
            
            // 🔧 Slightly smaller icons on iPad
            let iconScaleFactor = baseIconScaleFactor * (isPad ? 0.70 : 1.0)
            let adjustedIconSize = iconSize * iconScaleFactor

            VStack(spacing: 0) {
                // MARK: - Streak
                StreakRowView(
                    title: "Current Streak",
                    count: streakCount,
                    imageName: "streak_icon",
                    countColor: streakColor,
                    iconSize: adjustedIconSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeightAdjusted)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [streakBackgroundStart, streakBackgroundEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(radius, corners: [.topLeft, .topRight])
                .overlay(
                    // Streak section drop shadow
                    Rectangle()
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 2)
                        .offset(y: rowHeightAdjusted/2)
                        .blur(radius: 1)
                        .clipped()
                )
                
                Divider().opacity(0.15)

                // MARK: - Total Drawings
                StreakRowView(
                    title: "Total Drawings",
                    count: totalDrawings,
                    imageName: "pencil_art_icon",
                    countColor: drawingsColor,
                    iconSize: adjustedIconSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeightAdjusted)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [drawingsBackgroundStart, drawingsBackgroundEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    // Drawings section drop shadow
                    Rectangle()
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 2)
                        .offset(y: rowHeightAdjusted/2)
                        .blur(radius: 1)
                        .clipped()
                )

                Divider().opacity(0.15)

                // MARK: - Member Since
                StreakRowView(
                    title: "Member Since",
                    count: memberSince,
                    imageName: "member_since",
                    countColor: memberColor,
                    iconSize: adjustedIconSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeightAdjusted)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [memberBackgroundStart, memberBackgroundEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(radius, corners: [.bottomLeft, .bottomRight])
            }
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - StreakRowView
struct StreakRowView: View {
    let title: String
    let count: Any // Can be Int or String
    let imageName: String
    let countColor: Color
    let iconSize: CGFloat
    let fontScalingFactor: CGFloat
    
    private let baseLeadingPadding: CGFloat = 20
    private let baseTrailingPadding: CGFloat = 20
    private let baseCountTopPadding: CGFloat = 10
    private let baseIconTopOffset: CGFloat = -25
    
    var body: some View {
        GeometryReader { geometry in
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let scaling = isIpad ? 0.9 : 1.0  // Reduce iPad scaling to prevent overlap
            
            HStack(alignment: .top) {
                // Count + Title
                VStack(alignment: .leading, spacing: 2 * fontScalingFactor) {
                    Text(count is Int ? "\(count as! Int)" : "\(count as! String)")
                        .font(.system(size: (65 * fontScalingFactor * scaling) * 1.1, weight: .bold))
                        .foregroundColor(countColor)
                    
                    Text(title)
                        .font(.system(size: 16 * fontScalingFactor * scaling))
                        .foregroundColor(.black.opacity(0.65))
                }
                .padding(.top, baseCountTopPadding * fontScalingFactor)
                
                Spacer()
                
                // Icon Image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize * scaling, height: iconSize * scaling)
                    .alignmentGuide(.top) { d in d[.top] }
                    .padding(.trailing, baseTrailingPadding * fontScalingFactor)
                    .padding(.top, baseIconTopOffset)
            }
            .padding(.leading, baseLeadingPadding * fontScalingFactor)
        }
    }
}
