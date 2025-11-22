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
            
            // MATCH CARD 2 DIMENSIONS
            let cardWidth = width * 0.97
            let cardHeight = height * 0.97
            
            ZStack {
                Color.clear
                
                // The Card Container
                ZStack {
                    
                    // 1. IMAGE BACKGROUND
                    Image("card2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                    
                    // 2. AVATAR (Moved up 20%)
                    if customization.showAvatar, let profile = userProfile {
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
                    VStack {
                        Spacer()
                        
                        HStack {
                            if customization.showUsername, let profile = userProfile {
                                Text("@\(profile.displayName)")
                                    .font(.system(size: 28, weight: .black))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .padding(.leading, 50) // Shifted right
                                    .padding(.bottom, cardHeight * 0.25) // 25% from bottom = 75% from top
                                    .frame(maxWidth: cardWidth * 0.8, alignment: .leading)
                            }
                            Spacer()
                        }
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
