//
//  CardTemplateFiveView.swift
//  brush
//
//  Created by Meidad Troper on 11/23/25.
//

import SwiftUI

struct CardTemplateFiveView: View {
    @Binding var customization: CardCustomization
    @Binding var selectedDrawing: Item?
    var showUsername: Bool
    var showPrompt: Bool
    var userProfile: UserProfile?
    var onTapAddDrawing: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // MATCH CARD DIMENSIONS - scale down when drawing is loaded
            let scaleFactor: CGFloat = selectedDrawing != nil ? 0.80 : 0.97
            let cardWidth = width * scaleFactor
            let cardHeight = height * scaleFactor
            
            ZStack {
                Color.clear
                
                // The Card Container
                ZStack {
                    if let drawing = selectedDrawing, let drawingImage = drawing.image {
                        // LOADED STATE: Show the drawing filling the card
                        Image(uiImage: drawingImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: cardHeight)
                            .clipped()
                        
                        // Text overlays with strong shadows
                        VStack {
                            // App logo at top right
                            HStack {
                                Spacer()
                                Image("app_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 57.5, height: 57.5)
                                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                                    .padding(.top, 5)
                                    .padding(.trailing, 30)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 12) {
                                if showPrompt {
                                    Text(drawing.prompt)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .shadow(color: .black.opacity(1.0), radius: 2, x: 0, y: 0)
                                        .shadow(color: .black.opacity(0.8), radius: 8, x: 0, y: 4)
                                        .shadow(color: .black.opacity(0.6), radius: 16, x: 0, y: 8)
                                        .padding(.horizontal, 30)
                                }
                                
                                if showUsername, let profile = userProfile {
                                    Text("@\(profile.displayName)")
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(hex: "#FFD700") ?? .yellow, Color(hex: "#FF4500") ?? .orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: .black.opacity(1.0), radius: 2, x: 0, y: 0)
                                        .shadow(color: .black.opacity(0.8), radius: 6, x: 0, y: 3)
                                        .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 6)
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    } else {
                        // EMPTY STATE: card-custom with + button
                        Image("card-custom")
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: cardHeight)
                            .clipped()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 64, weight: .light))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("Add Drawing")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 15)
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedDrawing == nil {
                        onTapAddDrawing()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
