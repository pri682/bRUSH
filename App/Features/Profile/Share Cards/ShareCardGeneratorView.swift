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
        case 0:
            return [
                Color(hex: "#CC522A") ?? .orange,
                Color(hex: "#D66A2E") ?? .orange,
                Color(hex: "#D68645") ?? .orange
            ]
        case 1:
            return [
                Color(hex: "#B0186E") ?? .pink,
                Color(hex: "#8F0F63") ?? .purple,
                Color(hex: "#6D3B74") ?? .purple
            ]
        case 2:
            return [
                Color(hex: "#1E445A") ?? .blue,
                Color(hex: "#356B7F") ?? .blue,
                Color(hex: "#4FA5B8") ?? .cyan
            ]
        case 3:
            return [
                Color(hex: "#7A0040") ?? .pink,
                Color(hex: "#C0282E") ?? .red,
                Color(hex: "#FF5400") ?? .orange
            ]
        case 4:
            return [
                Color(hex: "#054336") ?? .green,
                Color(hex: "#065F46") ?? .green,
                Color(hex: "#10B981") ?? .teal
            ]
        default:
            return [.orange, .yellow, .red]
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(colors: gradientColors(for: selectedTemplateIndex), templateIndex: selectedTemplateIndex)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.8), value: selectedTemplateIndex)
                
                ShareCardPreviewView(
                    backgroundColor: $backgroundColor,
                    cardColor: $cardColor,
                    cardText: $cardText,
                    textColor: $textColor,
                    userProfile: userProfile,
                    currentPage: $selectedTemplateIndex
                )
            }
            .navigationTitle("Share Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark)
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
