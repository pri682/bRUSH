//
//  ShareCardNavButton.swift
//  brush
//
//  Created by Meidad Troper on 11/18/25.
//


//
//  ShareCardNavButton.swift
//  brush
//
//  Created by Meidad Troper on 11/18/25.
//
import SwiftUI
/// A custom button used for the Liquid Glass Nav Bar
struct ShareCardNavButton: View {
    let title: String
    @Binding var selection: String
    let namespace: Namespace.ID
    let isSelected: Bool
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selection = title
            }
        }) {
            VStack(spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .gray)
                
                // The moving highlight bar (Liquid Glass effect)
                if isSelected {
                    Color.white
                        .frame(height: 3)
                        // This links the bar's position between buttons
                        .matchedGeometryEffect(id: "navBarLine", in: namespace)
                } else {
                    Color.clear.frame(height: 3)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // Makes the whole area tappable
        }
    }
}


