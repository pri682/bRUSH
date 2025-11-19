import SwiftUI

struct ShareCardGeneratorView: View {
    let userProfile: UserProfile
    
    // MARK: - State
    @State private var currentTab: String = "Preview"
    
    // Customization State
    @State private var backgroundColor: Color = Color(hex: "#1A237E") ?? .blue
    @State private var cardColor: Color = Color(hex: "#2A2A72") ?? .indigo
    @State private var cardText: String = "LET'S\nGOO"
    @State private var textColor: Color = Color(hex: "#FF5252") ?? .red
    
    let tabs = ["Preview", "Edit"]
    @Namespace private var animation
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            // Global Background
            backgroundColor
                .ignoresSafeArea()
            
            // MARK: - Main Content
            ZStack {
                if currentTab == "Preview" {
                    ShareCardPreviewView(
                        backgroundColor: $backgroundColor,
                        cardColor: $cardColor,
                        cardText: $cardText,
                        textColor: $textColor
                    )
                    .transition(.opacity)
                } else {
                    ShareCardEditView(
                        backgroundColor: $backgroundColor,
                        cardColor: $cardColor,
                        cardText: $cardText,
                        textColor: $textColor
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentTab)
            
            // MARK: - Liquid Glass Nav
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(tabs, id: \.self) { tab in
                            Text(tab)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(currentTab == tab ? .black : .white.opacity(0.7))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background {
                                    if currentTab == tab {
                                        Capsule()
                                            .fill(Color.white)
                                            .matchedGeometryEffect(id: "activeTab", in: animation)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        currentTab = tab
                                    }
                                }
                        }
                    }
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
                    
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}
