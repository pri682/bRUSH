import SwiftUI
import Lottie

struct StreakUpdateView: View {
    @Binding var isShowing: Bool
    
    @State private var plusOneScale: CGFloat = 0.1
    @State private var plusOneOpacity: Double = 0
    @State private var plusOneOffset: CGFloat = 0
    
    @State private var playbackMode: LottiePlaybackMode = .paused

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: -60) {
                
                Text("+1")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .orange.opacity(0.8), radius: 10)
                    .scaleEffect(plusOneScale)
                    .opacity(plusOneOpacity)
                    .offset(y: plusOneOffset)
                
                LottieView(animation: .named("fire"))
                    .playbackMode(playbackMode)
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            runAnimationSequence()
        }
    }
    
    private func runAnimationSequence() {
        playbackMode = .playing(.toProgress(1, loopMode: .loop))

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            plusOneScale = 1.0
            plusOneOpacity = 1.0
            plusOneOffset = -50
        }
        
        withAnimation(.easeIn(duration: 0.5).delay(1.0)) {
            plusOneOpacity = 0.0
            plusOneOffset = -150
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isShowing = false
            }
        }
    }
}
