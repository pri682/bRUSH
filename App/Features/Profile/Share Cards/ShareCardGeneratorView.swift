import SwiftUI

struct ShareCardGeneratorView: View {
    let userProfile: UserProfile
    
    // MARK: - State
    @State private var currentTab: String = "Preview"
    
    // Customization State
    @State private var backgroundColor: Color = Color(hex: "#FFA500") ?? .orange
    @State private var cardColor: Color = Color(hex: "#FFD700") ?? .yellow
    @State private var cardText: String = "BRUSH"
    @State private var textColor: Color = Color(hex: "#8B4513") ?? .brown
    @State private var showUsername: Bool = true
    @State private var showAvatar: Bool = true
    
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
                        textColor: $textColor,
                        showUsername: $showUsername,
                        showAvatar: $showAvatar,
                        userProfile: userProfile // Pass profile
                    )
                    .transition(.opacity)
                } else {
                    // Passing transparent bg to edit view so it floats nicely
                    ShareCardEditView(
                        backgroundColor: $backgroundColor,
                        cardColor: $cardColor,
                        cardText: $cardText,
                        textColor: $textColor,
                        showUsername: $showUsername,
                        showAvatar: $showAvatar
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Custom Tab Header
            VStack {
                HStack(spacing: 20) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 40, height: 40)
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(tabs, id: \.self) { tab in
                            Text(tab)
                                .font(.system(size: 16, weight: .bold))
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
