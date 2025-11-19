import SwiftUI

struct ShareCardPreviewView: View {
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    @Binding var cardText: String
    @Binding var textColor: Color
    
    // Added userProfile
    var userProfile: UserProfile?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                
                // Create binding for the template
                let customizationBinding = Binding<CardCustomization>(
                    get: {
                        CardCustomization(
                            backgroundColor: backgroundColor,
                            cardColor: cardColor,
                            cardText: cardText,
                            textColor: textColor,
                            cardIcon: .user // Icon logic handled inside template
                        )
                    },
                    set: { _ in }
                )
                
                // Use the dynamic template
                CardTemplateTwoView(customization: customizationBinding, userProfile: userProfile)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
