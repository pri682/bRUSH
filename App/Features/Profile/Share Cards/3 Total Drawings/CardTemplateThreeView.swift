import SwiftUI

struct CardTemplateThreeView: View {
    @Binding var customization: CardCustomization
    var userProfile: UserProfile?
    
    var body: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            let cardHeight = geo.size.height
            
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
                        
                        VStack(spacing: -5) {
                            Text("@\(profile.displayName)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                            
                            Text(isOver100M ? "100 MILLION!" : "\(profile.totalDrawingCount)")
                                .font(.system(size: 96, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#FF8C00") ?? .orange,
                                            Color(hex: "#FF4500") ?? .red
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                                .frame(width: cardWidth * 0.5)
                            
                            VStack(spacing: 2) {
                                Text("Total Drawings")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                
                                if isOver100M {
                                    Text("The Card can't show more than that! You did it!")
                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                                        .padding(.top, 2)
                                }
                            }
                        }
                        .frame(width: cardWidth, alignment: .center)
                        .padding(.bottom, cardHeight * 0.08)
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
