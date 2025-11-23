import SwiftUI

struct ShareCardGeneratorView: View {
    let userProfile: UserProfile
    
    // MARK: - State
    @State private var selectedTemplateIndex: Int = 0
    
    // Customization State (kept for compatibility)
    @State private var backgroundColor: Color = Color(hex: "#FFA500") ?? .orange
    @State private var cardColor: Color = Color(hex: "#FFD700") ?? .yellow
    @State private var cardText: String = "BRUSH"
    @State private var textColor: Color = Color(hex: "#8B4513") ?? .brown
    
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
        case 4: // Custom Drawing - Purple/Lavender theme
            return [
                Color(hex: "#B794F6") ?? .purple,
                Color(hex: "#E9D5FF") ?? .purple,
                Color(hex: "#DDD6FE") ?? .purple
            ]
        default:
            return [.orange, .yellow, .red]
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // MARK: - Animated Background Gradient
            AnimatedGradientBackground(colors: gradientColors(for: selectedTemplateIndex), templateIndex: selectedTemplateIndex)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: selectedTemplateIndex)
            
            // MARK: - Main Content - Just the Preview
            ShareCardPreviewView(
                backgroundColor: $backgroundColor,
                cardColor: $cardColor,
                cardText: $cardText,
                textColor: $textColor,
                userProfile: userProfile,
                currentPage: $selectedTemplateIndex
            )
            
            // MARK: - Close Button (Top Right)
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .padding(.top, 20)
            .padding(.trailing, 20)
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    let colors: [Color]
    let templateIndex: Int
    @State private var animateGradient = false
    @State private var isAnimating = false
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            startAnimation()
        }
        .onChange(of: templateIndex) { _ in
            // Stop animation when template changes
            isAnimating = false
            animateGradient = false
            
            // Restart animation after 1 second delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            animateGradient.toggle()
        }
    }
}
