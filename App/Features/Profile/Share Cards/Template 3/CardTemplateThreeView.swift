//
//  CardTemplateThreeView.swift
//  brush
//
//  Created by Meidad Troper on 11/19/25.
//

import SwiftUI

struct CardTemplateThreeView: View {
    @Binding var customization: CardCustomization
    var userProfile: UserProfile?
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // MATCH CARD DIMENSIONS
            let cardWidth = width * 0.97
            let cardHeight = height * 0.97
            
            ZStack {
                Color.clear
                
                // The Card Container
                ZStack {
                    
                    // 1. IMAGE BACKGROUND
                    Image("card_total-drawings")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                    
                    // 2. TOTAL DRAWINGS DATA
                    if let profile = userProfile {
                        let isOver100M = profile.totalDrawingCount > 99_999_999
                        
                        VStack(spacing: -5) {
                            Text("@\(profile.displayName)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                                .padding(.bottom, 5)
                            
                            Text(isOver100M ? "100 MILLION!" : "\(profile.totalDrawingCount)")
                                .font(.system(size: 96, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF8C00") ?? .orange, Color(hex: "#FF4500") ?? .red],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                                .padding(.horizontal, 50)
                            
                            VStack(spacing: 2) {
                                Text("Total Drawings")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                
                                if isOver100M {
                                    Text("The Card can't show more than that! you did it!")
                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                                        .padding(.top, 2)
                                }
                            }
                        }
                        // Position in the lower half, centered horizontally, but higher up than template 1
                        .frame(maxWidth: .infinity)
                        .padding(.top, cardHeight * 0.40)
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
