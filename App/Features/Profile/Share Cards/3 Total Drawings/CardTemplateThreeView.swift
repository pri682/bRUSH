import SwiftUI

struct CardTemplateThreeView: View {
    @Binding var customization: CardCustomization
    var userProfile: UserProfile?
    var isExporting: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let cardHeight = geo.size.height
            
            let usernameFontSize = cardHeight * 0.04
            let titleFontSize = cardHeight * 0.048
            let noteFontSize = cardHeight * 0.02
            let countFontSize = cardHeight * 0.2
            
            ZStack {
                Color.clear
                
                ZStack(alignment: .bottom) {
                    
                    Image("card_total-drawings")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                    
                    if let profile = userProfile {
                        let isOver100M = profile.totalDrawingCount > 99_999_999
                        
                        let outlineThickness = cardWidth * 0.0035
                        let diagonalOffset = outlineThickness / 1.4142
                        
                        VStack(spacing: 0) {
                            Text("@\(profile.displayName)")
                                .font(.system(size: usernameFontSize, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: isExporting ? .clear : .black.opacity(0.8), radius: 2, x: 1, y: 1)
                            
                            ZStack {
                                let content = Group {
                                    if isOver100M {
                                        VStack(spacing: -countFontSize * 0.15) {
                                            Text("100")
                                                .font(.system(size: countFontSize * 0.7, weight: .black, design: .rounded))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.3)
                                            
                                            Text("MILLION!")
                                                .font(.system(size: countFontSize * 0.4, weight: .black, design: .rounded))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.3)
                                        }
                                    } else {
                                        Text("\(profile.totalDrawingCount)")
                                            .font(.system(size: countFontSize, weight: .black, design: .rounded))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.3)
                                    }
                                }
                                
                                Group {
                                    if !isExporting {
                                        content.offset(x: outlineThickness, y: 0)
                                        content.offset(x: -outlineThickness, y: 0)
                                        content.offset(x: 0, y: outlineThickness)
                                        content.offset(x: 0, y: -outlineThickness)
                                        
                                        content.offset(x: diagonalOffset, y: diagonalOffset)
                                        content.offset(x: -diagonalOffset, y: -diagonalOffset)
                                        content.offset(x: diagonalOffset, y: -diagonalOffset)
                                        content.offset(x: -diagonalOffset, y: diagonalOffset)
                                    }
                                }
                                .foregroundColor(.black)
                                
                                content
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#FFE600")!,
                                                Color(hex: "#FF9C00")!
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                            .drawingGroup()
                            .shadow(color: isExporting ? .clear : .black.opacity(0.4), radius: 4, x: 0, y: 2)
                            .multilineTextAlignment(.center)
                            .frame(width: cardWidth * 0.85)
                            
                            VStack(spacing: 2) {
                                Text("Total Drawings")
                                    .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: isExporting ? .clear : .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                
                                if isOver100M {
                                    Text("The Card can't show more than that! You did it!")
                                        .font(.system(size: noteFontSize, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.3), radius: 1, x: 0, y: 1)
                                        .padding(.top, 2)
                                }
                            }
                        }
                        .frame(width: cardWidth, alignment: .center)
                        .padding(.bottom, cardHeight * 0.04)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Image("brush_logo_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: cardWidth * 0.18)
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
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
