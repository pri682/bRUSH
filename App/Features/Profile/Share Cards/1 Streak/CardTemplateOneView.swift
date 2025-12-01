import SwiftUI

struct CardTemplateOneView: View {
    @Binding var customization: CardCustomization
    var userProfile: UserProfile?
    var isExporting: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let cardHeight = geo.size.height
            
            let countFontSize = cardHeight * 0.19
            let titleFontSize = cardHeight * 0.04
            let usernameFontSize = cardHeight * 0.028
            
            ZStack {
                Color.clear
                
                ZStack(alignment: .bottom) {
                    Image("card_streak")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                    
                    if let profile = userProfile {
                        
                        let outlineThickness = cardWidth * 0.0035
                        let diagonalOffset = outlineThickness / 1.4142
                        
                        VStack(spacing: -5) {
                            
                            ZStack {
                                Group {
                                    Text("\(profile.streakCount)").offset(x: outlineThickness, y: 0)
                                    Text("\(profile.streakCount)").offset(x: -outlineThickness, y: 0)
                                    Text("\(profile.streakCount)").offset(x: 0, y: outlineThickness)
                                    Text("\(profile.streakCount)").offset(x: 0, y: -outlineThickness)
                                    
                                    Text("\(profile.streakCount)").offset(x: diagonalOffset, y: diagonalOffset)
                                    Text("\(profile.streakCount)").offset(x: -diagonalOffset, y: -diagonalOffset)
                                    Text("\(profile.streakCount)").offset(x: diagonalOffset, y: -diagonalOffset)
                                    Text("\(profile.streakCount)").offset(x: -diagonalOffset, y: diagonalOffset)
                                }
                                .font(.system(size: countFontSize, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                
                                Text("\(profile.streakCount)")
                                    .font(.system(size: countFontSize, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "#FFD700") ?? .yellow,
                                                     Color(hex: "#FF4500") ?? .orange],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                
                            }
                            .drawingGroup()
                            .shadow(color: isExporting ? .clear : (Color(hex: "#FF4500")?.opacity(0.5)
                                    ?? .orange.opacity(0.5)),
                                    radius: 10, x: 0, y: 5)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                            .padding(.horizontal, 50)
                            
                            Text("Current Streak")
                                .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: isExporting ? .clear : .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .padding(.top, 5)
                            
                            Text("@\(profile.displayName)")
                                .font(.system(size: usernameFontSize, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: isExporting ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, cardHeight * 0.06)
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
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
            }
        }
    }
}
