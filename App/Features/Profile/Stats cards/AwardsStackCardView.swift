import SwiftUI

struct AwardsStackCardView: View {
    let cardTypeTitle: String
    let firstPlaceCount: Int
    let secondPlaceCount: Int
    let thirdPlaceCount: Int
    let medalIconSize: CGFloat
    var isCurrentUser: Bool = false

    private let baseMedalScaleFactor: CGFloat = 1.8

    private let goldNumberColor = Color(hex: "#ff9c00")!
    private let goldBackgroundStart = Color(hex: "#f8f1d5")!
    private let goldBackgroundEnd = Color(hex: "#eadba7")!
    
    private let silverNumberColor = Color(red: 90/255, green: 80/255, blue: 70/255)
    private let silverBackgroundStart = Color(hex: "#e2e4e3")!
    private let silverBackgroundEnd = Color(hex: "#b1b6b2")!
    
    private let bronzeNumberColor = Color(hex: "#8c5735")!
    private let bronzeBackgroundStart = Color(hex: "#dcc3ad")!
    private let bronzeBackgroundEnd = Color(hex: "#c98954")!

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
                    countColor: goldNumberColor,
                    medalIconSize: adjustedMedalSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeight)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [goldBackgroundStart, goldBackgroundEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(radius, corners: [.topLeft, .topRight])
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 2)
                        .offset(y: rowHeight/2)
                        .blur(radius: 1)
                        .clipped()
                )
                
                Divider().opacity(0.15)

                MedalRowView(
                    title: cardTypeTitle.contains("Accumulated") ? accumulatedTitle : awardedTitle,
                    count: secondPlaceCount,
                    imageName: "silver_medal",
                    countColor: silverNumberColor,
                    medalIconSize: adjustedMedalSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeight)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [silverBackgroundStart, silverBackgroundEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 2)
                        .offset(y: rowHeight/2)
                        .blur(radius: 1)
                        .clipped()
                )

                Divider().opacity(0.15)

                MedalRowView(
                    title: cardTypeTitle.contains("Accumulated") ? accumulatedTitle : awardedTitle,
                    count: thirdPlaceCount,
                    imageName: "bronze_medal",
                    countColor: bronzeNumberColor,
                    medalIconSize: adjustedMedalSize,
                    fontScalingFactor: fontFactor
                )
                .frame(height: rowHeight)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [bronzeBackgroundStart, bronzeBackgroundEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(radius, corners: [.bottomLeft, .bottomRight])
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
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
