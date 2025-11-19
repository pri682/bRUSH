//
//  CardTemplateOneView.swift
//  brush
//
//  Created by Meidad Troper on 11/19/25.
//


import SwiftUI

/// TEMPLATE 1: The visual template for Card Type 1 (The original Poster design, now with an Icon).
struct CardTemplateOneView: View {
    // This template receives the central customization state
    @Binding var customization: CardCustomization
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                
                // The Card Container
                ZStack(alignment: .center) {
                    // 1. Card Background
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(customization.cardColor)
                    
                    // 2. The Text & Icon Stack
                    VStack {
                        // Icon Placement (Top Left Corner of the text area)
                        if customization.cardIcon != .none {
                            HStack {
                                Image(systemName: customization.cardIcon.systemName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(customization.cardIcon.iconColor)
                                    .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 3)
                                
                                Spacer()
                            }
                            .padding(.top, 40)
                            .padding(.leading, 30)
                        } else {
                            // Spacer to maintain consistent vertical position if no icon
                            Spacer().frame(height: customization.cardIcon == .none ? 0 : 90) 
                        }
                        
                        // Main Text
                        Text(customization.cardText.uppercased())
                            // Black weight + Italic = Sporty/Fast look
                            .font(.system(size: 200, weight: .black))
                            .italic()
                            .foregroundColor(customization.textColor)
                            .multilineTextAlignment(.center)
                            .lineSpacing(-20) // Tighten line height
                            .minimumScaleFactor(0.1)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .blendMode(.multiply) // Apply multiply blend mode for visual depth
                        
                        Spacer()
                    }
                }
                // Masking ensures content respects corners
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 15)
                .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.65)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}