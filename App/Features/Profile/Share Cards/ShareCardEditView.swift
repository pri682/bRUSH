//
//  ShareCardEditView.swift
//  brush
//
//  Created by Meidad Troper on 11/18/25.
//


//
//  ShareCardEditView.swift
//  brush
//
//  Created by Meidad Troper on 11/18/25.
//
import SwiftUI
struct ShareCardEditView: View {
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                // Spacer to push content down below the floating nav bar
                Color.clear.frame(height: 80)
                
                Text("Customize Appearance")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                // Controls Container
                VStack(spacing: 20) {
                    
                    // 1. Background Color Picker
                    HStack {
                        Text("Background Color")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Spacer()
                        ColorPicker("", selection: $backgroundColor, supportsOpacity: false)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 2. Card Color Picker
                    HStack {
                        Text("Card Color")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Spacer()
                        ColorPicker("", selection: $cardColor, supportsOpacity: false)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Add more options here later (e.g., Overlay opacity, Corner Radius)
                }
                .padding(.horizontal)
                
            }
        }
        // This lets us see the background color change in real-time behind the edit menu
        .background(Color.black.opacity(0.2)) 
    }
}


