import SwiftUI

struct CardTemplateFourView: View {
    @Binding var customization: CardCustomization
    var userProfile: UserProfile?
    var isExporting: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let cardHeight = geo.size.height
            
            ZStack {
                Color.clear
                
                ZStack(alignment: .bottom) {
                    Image("card_member-since")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                    
                    if let profile = userProfile {
                        let memberYear = UserService.formatMemberSinceDate(profile.memberSince).year
                        
                        let outlineThickness = cardWidth * 0.0035
                        let diagonalOffset = outlineThickness / 1.4142
                        let yearFontSize = cardHeight * 0.2
                        
                        VStack(spacing: 0) {
                            Text("Member Since")
                                .font(.system(size: cardHeight * 0.04, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: isExporting ? .clear : .black.opacity(0.5), radius: 3, x: 0, y: 2)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            ZStack {
                                Group {
                                    if !isExporting {
                                        Text(memberYear).offset(x: outlineThickness, y: 0)
                                        Text(memberYear).offset(x: -outlineThickness, y: 0)
                                        Text(memberYear).offset(x: 0, y: outlineThickness)
                                        Text(memberYear).offset(x: 0, y: -outlineThickness)
                                        
                                        Text(memberYear).offset(x: diagonalOffset, y: diagonalOffset)
                                        Text(memberYear).offset(x: -diagonalOffset, y: -diagonalOffset)
                                        Text(memberYear).offset(x: diagonalOffset, y: -diagonalOffset)
                                        Text(memberYear).offset(x: -diagonalOffset, y: diagonalOffset)
                                    }
                                }
                                .font(.system(size: yearFontSize, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                
                                Text(memberYear)
                                    .font(.system(size: yearFontSize, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#A9D91D") ?? .green,
                                                Color(hex: "#F4EDC7") ?? .white
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                
                            }
                            .drawingGroup()
                            .shadow(color: isExporting ? .clear : .black.opacity(0.4), radius: 6, x: 0, y: 3)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, cardWidth * 0.07)
                        .padding(.bottom, cardHeight * 0.04)
                    }
                    
                    VStack {
                        HStack {
                            Image("brush_logo_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: cardWidth * 0.18)
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                                .padding(.top, cardHeight * 0.04)
                                .padding(.leading, cardWidth * 0.05)
                            Spacer()
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
