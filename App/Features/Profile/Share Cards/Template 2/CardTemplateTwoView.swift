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
                    

                    

                }
                .frame(width: cardWidth, height: cardHeight)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
