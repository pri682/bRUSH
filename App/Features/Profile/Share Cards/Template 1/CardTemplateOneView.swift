//
//  CardTemplateOneView.swift
//  brush
//
//  Created by Meidad Troper on 11/19/25.
//

import SwiftUI

struct CardTemplateOneView: View {
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
                    Image("card_streak")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                                        // 2. APP LOGO (Top Right)

                    
                    // 3. STREAK DATA
                    if let profile = userProfile {
                        VStack(spacing: -5) {
                            Text("@\(profile.displayName)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1) // Stronger shadow for visibility
                                .padding(.bottom, 5)
                            
                            Text("\(profile.streakCount)")
                                .font(.system(size: 96, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#FFD700") ?? .yellow, Color(hex: "#FF4500") ?? .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color(hex: "#FF4500")?.opacity(0.5) ?? .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                                .minimumScaleFactor(0.3) // Allow scaling down further for 6+ digits
                                .lineLimit(1)
                                .padding(.horizontal, 50) // More padding to ensure it doesn't touch edges
                            
                            Text("Day streak!")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                        // Position in the lower half, centered horizontally
                        .frame(maxWidth: .infinity)
                        .padding(.top, cardHeight * 0.45) 
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
