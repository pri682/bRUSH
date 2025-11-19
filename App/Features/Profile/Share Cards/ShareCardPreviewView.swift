//
//  ShareCardPreviewView.swift
//  brush
//
//  Created by Meidad Troper on 11/18/25.
//


import SwiftUI
struct ShareCardPreviewView: View {
    // Bindings allow the preview to update instantly when colors change
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: The container background is handled in the parent view,
                // but we can add a subtle gradient overlay here if we want later.
                Color.clear
                
                // Layer 2: The Actual Card
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(cardColor)
                    // The Shadow makes it pop off the background
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    // Aspect Ratio similar to the reference image (phone screen shape)
                    .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.65)
                    .overlay(
                        // Placeholder for future content content
                        VStack {
                            // Content removed as requested
                        }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


