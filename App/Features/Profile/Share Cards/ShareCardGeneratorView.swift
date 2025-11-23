import SwiftUI

struct ShareCardGeneratorView: View {
    let userProfile: UserProfile
    
    // MARK: - State
    // MARK: - State
    @State private var currentTab: String = "Preview"
    @State private var selectedTemplateIndex: Int = 0
    
    // Customization State
    @State private var backgroundColor: Color = Color(hex: "#FFA500") ?? .orange
    @State private var cardColor: Color = Color(hex: "#FFD700") ?? .yellow
    @State private var cardText: String = "BRUSH"
    @State private var textColor: Color = Color(hex: "#8B4513") ?? .brown
    
    let tabs = ["Preview", "Edit"]
    @Namespace private var animation
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Background Gradient Colors for Each Template
    // Based on dominant colors from each card background
    private func gradientColors(for templateIndex: Int) -> [Color] {
        switch templateIndex {
        case 0: // Streak Card - Fire/Orange theme
            return [
                Color(hex: "#FF6B35") ?? .orange,
                Color(hex: "#FF8C42") ?? .orange,
                Color(hex: "#FFAA5A") ?? .orange
            ]
        case 1: // Medals Card - Pink/Purple theme
            return [
                Color(hex: "#E91E8C") ?? .pink,
                Color(hex: "#C71585") ?? .purple,
                Color(hex: "#9B4F96") ?? .purple
            ]
        case 2: // Total Drawings - Blue theme
            return [
                Color(hex: "#2C5F7C") ?? .blue,
                Color(hex: "#4A90A4") ?? .blue,
                Color(hex: "#76C1D4") ?? .cyan
            ]
        case 3: // Member Since - Maroon/Deep Red theme
            return [
                Color(hex: "#8B2635") ?? .red,
                Color(hex: "#A63446") ?? .red,
                Color(hex: "#C85A54") ?? .orange
            ]
        default:
            return [.orange, .yellow, .red]
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Animated Background Gradient
            AnimatedGradientBackground(colors: gradientColors(for: selectedTemplateIndex))
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: selectedTemplateIndex)
            
            // MARK: - Main Content
            ZStack {
                if currentTab == "Preview" {
                    ShareCardPreviewView(
                        backgroundColor: $backgroundColor,
                        cardColor: $cardColor,
                        cardText: $cardText,
                        textColor: $textColor,
                        userProfile: userProfile, // Pass profile
                        currentPage: $selectedTemplateIndex // Binding to sync
                    )
                    .transition(.opacity)
                } else {
                    // Passing transparent bg to edit view so it floats nicely
                    ShareCardEditView(
                        backgroundColor: $backgroundColor,
                        cardColor: $cardColor,
                        cardText: $cardText,
                        textColor: $textColor,
                        selectedTemplateIndex: selectedTemplateIndex, // Pass selected index
                        userProfile: userProfile
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

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    let colors: [Color]
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}
