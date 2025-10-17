import SwiftUI

struct AwardsStackCardView: View {
    let cardTypeTitle: String
    let firstPlaceCount: Int
    let secondPlaceCount: Int
    let thirdPlaceCount: Int
    let medalIconSize: CGFloat

    // Base medal scale
    private let baseMedalScaleFactor: CGFloat = 1.8

    // Colors
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

            // Device / size detection
            let isPad = UIDevice.current.userInterfaceIdiom == .pad || cardWidth > 600

            // Font & medal scaling
            let fontFactorBase = cardWidth / 400
            let fontFactor = fontFactorBase * (isPad ? 0.88 : 1.0)
            
            // 🔧 Slightly smaller medals on iPad
            let medalScaleFactor = baseMedalScaleFactor * (isPad ? 0.70 : 1.0)
            let adjustedMedalSize = medalIconSize * medalScaleFactor

            VStack(spacing: 0) {
                // MARK: - Gold
                MedalRowView(
                    title: cardTypeTitle.contains("Received") ? "First Place Awards" : "First Place Given",
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
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                
                Divider().opacity(0.15)

                // MARK: - Silver
                MedalRowView(
                    title: cardTypeTitle.contains("Received") ? "Second Place Awards" : "Second Place Given",
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
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)

                Divider().opacity(0.15)

                // MARK: - Bronze
                MedalRowView(
                    title: cardTypeTitle.contains("Received") ? "Third Place Awards" : "Third Place Given",
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
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Helpers
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
