import SwiftUI

struct ShareCardPreviewView: View {
    @Binding var backgroundColor: Color
    @Binding var cardColor: Color
    @Binding var cardText: String
    @Binding var textColor: Color
    @Binding var showUsername: Bool
    @Binding var showAvatar: Bool
    
    var userProfile: UserProfile?
    
    // Toggle to hide buttons in the Edit View mini-preview
    var showActions: Bool = true
    
    // Track current page for custom dots
    @State private var currentPage = 0
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            
            // Card logic (same as before)
            let customizationBinding = Binding<CardCustomization>(
                get: {
                    CardCustomization(
                        backgroundColor: backgroundColor,
                        cardColor: cardColor,
                        cardText: cardText,
                        textColor: textColor,
                        cardIcon: .user,
                        showUsername: showUsername,
                        showAvatar: showAvatar
                    )
                },
                set: { _ in }
            )
            
            ZStack {
                // 1. THE CAROUSEL (Cards)
                TabView(selection: $currentPage) {
                    CardTemplateOneView(customization: customizationBinding, userProfile: userProfile)
                        .tag(0)
                    
                    CardTemplateTwoView(customization: customizationBinding, userProfile: userProfile)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
                
                // 2. OVERLAY: Dots and Share Button
                if showActions {
                    VStack {
                        Spacer()
                        
                        // Custom Dots - Positioned closer to the card bottom
                        HStack(spacing: 8) {
                            ForEach(0..<2) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                    .animation(.spring(), value: currentPage)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Share Button with Liquid Glass Effect
                        Button(action: {
                            print("Share tapped") // Add your share logic here
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Share Card")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .padding(.bottom, height * 0.05) // Bottom padding relative to screen height
                        .buttonStyle(.glass) // Frosted glass background
                    }
                }
            }
        }
    }
}
