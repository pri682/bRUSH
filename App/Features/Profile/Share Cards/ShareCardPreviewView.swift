import SwiftUI

struct ShareCardPreviewView: View {
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    @Binding var cardText: String
    @Binding var textColor: Color
    
    var userProfile: UserProfile?
    
    var body: some View {
        GeometryReader { geometry in
            
            // Create binding for the template
            let customizationBinding = Binding<CardCustomization>(
                get: {
                    CardCustomization(
                        backgroundColor: backgroundColor,
                        cardColor: cardColor,
                        cardText: cardText,
                        textColor: textColor,
                        cardIcon: .user
                    )
                },
                set: { _ in }
            )
            
            // THE CAROUSEL
            TabView {
                // PAGE 1: Image Based (card_1)
                CardTemplateOneView(customization: customizationBinding, userProfile: userProfile)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .tag(0)
                
                // PAGE 2: Code Based (Dynamic Patterns)
                CardTemplateTwoView(customization: customizationBinding, userProfile: userProfile)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
            .onAppear {
                // This helps make the dots visible
                UIPageControl.appearance().currentPageIndicatorTintColor = .white
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
            }
        }
    }
}
