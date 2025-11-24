import SwiftUI

struct CardTemplateFourView: View {
    @Binding var customization: CardCustomization
    var userProfile: UserProfile?
    
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
                        
                        VStack(spacing: 0) {
                            Text("Member Since")
                                .font(.system(size: cardHeight * 0.04, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text(memberYear)
                                .font(.system(size: cardHeight * 0.2, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#90EE90") ?? .green,
                                            Color(hex: "#F5F5F0") ?? .white
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, cardWidth * 0.07)
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
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}
