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
            
            ZStack {
                Color.clear
                
                // The Card Container
                ZStack {
                    // 1. Base Card Background
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(customization.cardColor)
                        .clipped()
                    
                    // 2. The "Extended" Background Pattern
                    GeometryReader { innerGeo in
                        let lastChar = customization.cardText.last.map { String($0) } ?? ""
                        let extendedText = customization.cardText + String(repeating: lastChar, count: 800)
                        
                        Text(extendedText)
                            .font(.system(size: 32, weight: .black))
                            .textCase(.uppercase)
                            .foregroundColor(customization.textColor.opacity(0.12))
                            .lineSpacing(-10)
                            .multilineTextAlignment(.leading)
                            .frame(width: innerGeo.size.width * 1.5, height: innerGeo.size.height * 1.5, alignment: .topLeading)
                            .rotationEffect(.degrees(-5))
                            .offset(x: -20, y: -20)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    
                    // 3. THE AVATAR (Adjusted Size & Position)
                    if let profile = userProfile {
                        VStack {
                            Spacer()
                            
                            ZStack {
                                // Body
                                if let body = profile.avatarBody {
                                    Image(body).resizable().scaledToFit()
                                }
                                // Shirt (Personal only)
                                if profile.avatarType == "personal", let shirt = profile.avatarShirt {
                                    Image(shirt).resizable().scaledToFit()
                                }
                                // Eyes
                                if let eyes = profile.avatarEyes {
                                    Image(eyes).resizable().scaledToFit()
                                }
                                // Facial Hair (Personal only)
                                if profile.avatarType == "personal", let fHair = profile.avatarFacialHair {
                                    Image(fHair).resizable().scaledToFit()
                                }
                                // Mouth
                                if let mouth = profile.avatarMouth {
                                    Image(mouth).resizable().scaledToFit()
                                }
                                // Hair
                                if let hair = profile.avatarHair {
                                    Image(hair).resizable().scaledToFit()
                                }
                            }
                            // SIZE: Reduced from 1.2 to 0.9 (25% smaller)
                            .frame(width: width * 0.9)
                            // POSITION: Changed from 0.13 to 0.04 to move it HIGHER
                            .offset(y: height * 0.001)
                        }
                    }

                    // 4. Main Foreground Content
                    VStack(spacing: 10) {
                        Spacer()
                        
                        // Only show Icon if it's NOT the user avatar
                        if customization.cardIcon != .none && customization.cardIcon != .user {
                            Image(systemName: customization.cardIcon.systemName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(customization.textColor)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        
                        // Main Text
                        Text(customization.cardText.uppercased())
                            .font(.system(size: 50, weight: .black))
                            .italic()
                            .foregroundColor(customization.textColor)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
                            // Adjusted padding to account for the smaller, higher avatar
                            .padding(.bottom, height * 0.30)
                            .minimumScaleFactor(0.4)
                        
                        Spacer()
                    }
                    .padding()
                }
                .frame(width: width * 0.85, height: height * 0.65)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
