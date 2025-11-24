import SwiftUI

struct CardTemplateTwoView: View {
    @Binding var customization: CardCustomization
    var userProfile: UserProfile?
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let cardHeight = geo.size.height
            
            ZStack {
                Color.clear
                
                ZStack(alignment: .top) {
                    
                    Image("card_medals")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                    
                    if let profile = userProfile {
                        VStack(spacing: 0) {
                            
                            Spacer()
                                .frame(height: cardHeight * 0.40)
                            
                            VStack(spacing: -5) {
                                
                                let totalMedals =
                                    profile.goldMedalsAccumulated +
                                    profile.silverMedalsAccumulated +
                                    profile.bronzeMedalsAccumulated
                                
                                let isOver100M = totalMedals > 99_999_999
                                let isAbbreviated = totalMedals > 99_999
                                
                                let mainText: String = {
                                    if isOver100M { return "100M" }
                                    if isAbbreviated {
                                        return totalMedals.formatted(.number.notation(.compactName))
                                    }
                                    return "\(totalMedals)"
                                }()
                                
                                Text(mainText)
                                    .font(.system(size: 96, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#FF4500") ?? .pink,
                                                Color(hex: "#ffc411") ?? .yellow
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(
                                        color: Color(hex: "#FF1493")?.opacity(0.8)
                                            ?? .pink.opacity(0.8),
                                        radius: 20, x: 0, y: 0
                                    )
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                
                                let subText: String = {
                                    if isOver100M { return "OVER 100 MILLION!" }
                                    if isAbbreviated {
                                        return "\(totalMedals.formatted()) Medals Earned"
                                    }
                                    return "Medals Earned"
                                }()
                                
                                Text(subText)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(
                                        color: .black.opacity(0.5),
                                        radius: 2, x: 0, y: 1
                                    )
                                    .padding(.top, 5)
                                    .multilineTextAlignment(.center)
                                
                                Text("@\(profile.displayName)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                    .shadow(
                                        color: .black.opacity(0.5),
                                        radius: 2, x: 0, y: 1
                                    )
                                    .padding(.top, 10)
                                
                            }
                            .frame(width: cardWidth * 0.60)
                            
                            Spacer()
                        }
                        .frame(width: cardWidth, height: cardHeight, alignment: .top)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Image("brush_logo_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: cardWidth * 0.18)
                                .shadow(color: .black.opacity(0.4),
                                        radius: 4, x: 0, y: 2)
                                .padding(.top, cardHeight * 0.03)
                                .padding(.trailing, cardWidth * 0.04)
                        }
                        Spacer()
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}
