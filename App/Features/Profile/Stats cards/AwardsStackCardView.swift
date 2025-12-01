import SwiftUI

struct AwardsStackCardView: View {
    @Environment(\.colorScheme) var colorScheme
    let cardTypeTitle: String
    let firstPlaceCount: Int
    let secondPlaceCount: Int
    let thirdPlaceCount: Int
    let medalIconSize: CGFloat
    var isCurrentUser: Bool = false

    private let baseMedalScaleFactor: CGFloat = 1.8

    private let goldNumberColor = Color(hex: "#ff9c00") ?? .yellow
    private let goldNumberColorDark = Color(hex: "#FFC107") ?? .yellow
    
    private var goldBackgroundStart: Color {
        colorScheme == .dark ? (Color(hex: "#8B6914") ?? .yellow) : (Color(hex: "#f8f1d5") ?? .yellow.opacity(0.3))
    }
    private var goldBackgroundEnd: Color {
        colorScheme == .dark ? (Color(hex: "#58420A") ?? .orange) : (Color(hex: "#eadba7") ?? .yellow.opacity(0.6))
    }
    
    private let silverNumberColor = Color(red: 90/255, green: 80/255, blue: 70/255)
    private let silverNumberColorDark = Color(hex: "#E0E0E0") ?? .gray
    
    private var silverBackgroundStart: Color {
        colorScheme == .dark ? (Color(hex: "#696969") ?? .gray) : (Color(hex: "#e2e4e3") ?? .gray.opacity(0.3))
    }
    private var silverBackgroundEnd: Color {
        colorScheme == .dark ? (Color(hex: "#404040") ?? .gray) : (Color(hex: "#b1b6b2") ?? .gray.opacity(0.6))
    }
    
    private let bronzeNumberColor = Color(hex: "#8c5735") ?? .brown
    private let bronzeNumberColorDark = Color(hex: "#E6BE8A") ?? .orange
    
    private var bronzeBackgroundStart: Color {
        colorScheme == .dark ? (Color(hex: "#8D5524") ?? .brown) : (Color(hex: "#dcc3ad") ?? .brown.opacity(0.3))
    }
    private var bronzeBackgroundEnd: Color {
        colorScheme == .dark ? (Color(hex: "#543310") ?? .orange) : (Color(hex: "#c98954") ?? .brown.opacity(0.6))
    }

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let cardHeight = geometry.size.height
            let rowHeight = cardHeight / 3
            let radius = min(cardWidth, cardHeight) * 0.06

            let fontFactor = cardWidth / 380.0
            let adjustedMedalSize = medalIconSize * baseMedalScaleFactor
            
            let accumulatedTitle = isCurrentUser ? "Medals Received" : "Medals Received"
            let awardedTitle = isCurrentUser ? "Medals Given" : "Medals Given"

            VStack(spacing: 0) {
                MedalRowView(
                    title: cardTypeTitle.contains("Accumulated") ? accumulatedTitle : awardedTitle,
                    count: firstPlaceCount,
                    imageName: "gold_medal",
                    countColor: colorScheme == .dark ? goldNumberColorDark : goldNumberColor,
                    medalIconSize: adjustedMedalSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeight)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [goldBackgroundStart, goldBackgroundEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(radius, corners: [.topLeft, .topRight])
                .overlay(separatorOverlay(rowHeight: rowHeight))
                
                Divider().opacity(0.15)

                MedalRowView(
                    title: cardTypeTitle.contains("Accumulated") ? accumulatedTitle : awardedTitle,
                    count: secondPlaceCount,
                    imageName: "silver_medal",
                    countColor: colorScheme == .dark ? silverNumberColorDark : silverNumberColor,
                    medalIconSize: adjustedMedalSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeight)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [silverBackgroundStart, silverBackgroundEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(separatorOverlay(rowHeight: rowHeight))

                Divider().opacity(0.15)

                MedalRowView(
                    title: cardTypeTitle.contains("Accumulated") ? accumulatedTitle : awardedTitle,
                    count: thirdPlaceCount,
                    imageName: "bronze_medal",
                    countColor: colorScheme == .dark ? bronzeNumberColorDark : bronzeNumberColor,
                    medalIconSize: adjustedMedalSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeight)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [bronzeBackgroundStart, bronzeBackgroundEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(radius, corners: [.bottomLeft, .bottomRight])
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    private func separatorOverlay(rowHeight: CGFloat) -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.08))
            .frame(height: 2)
            .offset(y: rowHeight/2)
            .blur(radius: 1)
            .clipped()
    }
}

extension Color {
    init?(hex: String) {
        let hexColor = hex.replacingOccurrences(of: "#", with: "")
        var hexNumber: UInt64 = 0
        guard Scanner(string: hexColor).scanHexInt64(&hexNumber) else { return nil }
        let r = Double((hexNumber & 0xFF0000) >> 16) / 255.0
        let g = Double((hexNumber & 0x00FF00) >> 8) / 255.0
        let b = Double((hexNumber & 0x0000FF) >> 0) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
