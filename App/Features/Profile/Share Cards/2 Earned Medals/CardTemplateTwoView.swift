import SwiftUI

struct CardTemplateTwoView: View {
    @Binding var customization: CardCustomization
    var userProfile: UserProfile?
    var isExporting: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let cardHeight = geo.size.height
            
            let shadowColor = Color(hex: "#3F2D5B") ?? .purple
            
            let horizontalPadding = cardWidth * 0.075
            
            ZStack {
                Color.clear
                
                ZStack(alignment: .top) {
                    
                    Image("card_medals")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                    
                    if let profile = userProfile {
                        
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
                        
                        let countFontSize = cardHeight * 0.20
                        
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: cardHeight * 0.40)
                            
                            VStack(spacing: -5) {
                                Text(mainText)
                                    .font(.system(size: countFontSize, weight: .black, design: .rounded))
                                    .foregroundColor(shadowColor)
                                    .offset(x: cardWidth * 0.018, y: cardHeight * 0.010)
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, horizontalPadding)
                            }
                            .frame(width: cardWidth * 0.75)
                            
                            Spacer()
                        }
                        .frame(width: cardWidth, height: cardHeight, alignment: .top)
                        
                        VStack(spacing: 0) {
                            
                            Spacer()
                                .frame(height: cardHeight * 0.40)
                            
                            VStack(spacing: -5) {
                                
                                let outlineThickness = cardWidth * 0.0035
                                let diagonalOffset = outlineThickness / 1.4142
                                
                                ZStack {
                                    Group {
                                        if !isExporting {
                                            Text(mainText).offset(x: outlineThickness, y: 0)
                                            Text(mainText).offset(x: -outlineThickness, y: 0)
                                            Text(mainText).offset(x: 0, y: outlineThickness)
                                            Text(mainText).offset(x: 0, y: -outlineThickness)
                                            
                                            Text(mainText).offset(x: diagonalOffset, y: diagonalOffset)
                                            Text(mainText).offset(x: -diagonalOffset, y: -diagonalOffset)
                                            Text(mainText).offset(x: diagonalOffset, y: -diagonalOffset)
                                            Text(mainText).offset(x: -diagonalOffset, y: diagonalOffset)
                                        }
                                    }
                                    .font(.system(size: countFontSize, weight: .black, design: .rounded))
                                    .foregroundColor(.black)
                                    .drawingGroup()
                                    
                                    Text(mainText)
                                        .font(.system(size: countFontSize, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    .red,
                                                    .blue,
                                                    .yellow
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, horizontalPadding)
                                
                                if isOver100M {
                                    Text("OVER")
                                        .font(.system(size: cardHeight * 0.04, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                        .padding(.top, 5)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, horizontalPadding)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                    
                                    Text("100 MILLION!")
                                        .font(.system(size: cardHeight * 0.04, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                        .padding(.top, 10)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, horizontalPadding)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                        
                                } else if isAbbreviated {
                                    Text(totalMedals.formatted())
                                        .font(.system(size: cardHeight * 0.04, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                        .padding(.top, 5)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, horizontalPadding)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                    
                                    Text("Medals Earned")
                                        .font(.system(size: cardHeight * 0.04, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                        .padding(.top, 10)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, horizontalPadding)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                } else {
                                    Text("Medals Earned")
                                        .font(.system(size: cardHeight * 0.04, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: isExporting ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                        .padding(.top, 5)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, horizontalPadding)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                }
                                
                                Text("@\(profile.displayName)")
                                    .font(.system(size: cardHeight * 0.03, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                    .shadow(color: isExporting ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                    .padding(.top, 10)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, horizontalPadding)
                                
                            }
                            .frame(width: cardWidth * 0.75)
                            
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
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                                .padding(.top, cardHeight * 0.03)
                                .padding(.trailing, cardWidth * 0.04)
                        }
                        Spacer()
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
            }
        }
    }
}
