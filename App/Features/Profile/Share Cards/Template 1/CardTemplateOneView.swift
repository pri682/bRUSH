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
            
            // MATCH CARD 2 DIMENSIONS
            let cardWidth = width * 0.97
            let cardHeight = height * 0.97
            
            ZStack {
                Color.clear
                
                // The Card Container
                ZStack {
                    
                    // 1. IMAGE BACKGROUND
                    Image("card_1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                    
                    // 2. AVATAR (Moved up 20%)
                    if let profile = userProfile {
                        VStack {
                            Spacer()
                            
                            ZStack {
                                if let body = profile.avatarBody { Image(body).resizable().scaledToFit() }
                                if profile.avatarType == "personal", let shirt = profile.avatarShirt {
                                    Image(shirt).resizable().scaledToFit()
                                }
                                if let eyes = profile.avatarEyes { Image(eyes).resizable().scaledToFit() }
                                if profile.avatarType == "personal", let fHair = profile.avatarFacialHair {
                                    Image(fHair).resizable().scaledToFit()
                                }
                                if let mouth = profile.avatarMouth { Image(mouth).resizable().scaledToFit() }
                                if let hair = profile.avatarHair { Image(hair).resizable().scaledToFit() }
                            }
                            // 75% of card width
                            .frame(width: cardWidth * 1)
                            // LIFT AVATAR UP 20%
                            .offset(y: -height * 0.15)
                        }
                    }
                    
                    // 3. TEXT LAYER
                    VStack(spacing: 10) {
                        Spacer()
                        
                        // Main Text
                        Text(customization.cardText.uppercased())
                            .font(.system(size: 60, weight: .black))
                            .italic()
                            .foregroundColor(customization.textColor)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
                            // Padding adjusted relative to card height
                            .padding(.bottom, cardHeight * 0.42)
                            .minimumScaleFactor(0.4)
                        
                        Spacer()
                    }
                    .padding()
                }
                .frame(width: cardWidth, height: cardHeight)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
