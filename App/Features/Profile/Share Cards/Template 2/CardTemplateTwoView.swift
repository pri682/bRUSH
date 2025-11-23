//
//  CardTemplateTwoView.swift
//  brush
//
//  Created by Meidad Troper on 11/19/25.
//

import SwiftUI

struct CardTemplateTwoView: View {
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
                    Image("card_medals")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                                        // 2. MEDALS DATA
                    if let profile = userProfile {
                        // Use Awarded properties for total lifetime medals
                        let totalMedals = profile.goldMedalsAwarded + profile.silverMedalsAwarded + profile.bronzeMedalsAwarded
                        let isOver100M = totalMedals > 99_999_999
                        let isAbbreviated = totalMedals > 99_999
                        
                        VStack(spacing: -5) {
                            // Main Count Text
                            let mainText: String = {
                                if isOver100M { return "100M" }
                                if isAbbreviated { return totalMedals.formatted(.number.notation(.compactName)) }
                                return "\(totalMedals)"
                            }()
                            
                            Text(mainText)
                                .font(.system(size: 96, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF1493") ?? .pink, Color(hex: "#C71585") ?? .purple], // Slightly less bright/neon
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color(hex: "#FF1493")?.opacity(0.8) ?? .pink.opacity(0.8), radius: 20, x: 0, y: 0)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                                .padding(.horizontal, 100)
                            
                            // Subtext Label
                            let subText: String = {
                                if isOver100M { return "OVER 100 MILLION!" }
                                if isAbbreviated { return "\(totalMedals.formatted()) Medals Earned" }
                                return "Medals Earned"
                            }()
                            
                            Text(subText)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                .padding(.top, 5)
                            
                            // Username
                            Text("@\(profile.displayName)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                .padding(.top, 2)
                        }
                        // Position in the center
                        .frame(maxWidth: .infinity)
                        .offset(y: cardHeight * 0.06) // Move down significantly to center on card
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
