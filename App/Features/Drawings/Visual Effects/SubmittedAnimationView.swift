import SwiftUI
import Lottie

struct SubmittedAnimationView: View {
    @Binding var isShowing: Bool
    
    @State private var playbackMode: LottiePlaybackMode = .paused

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .transition(.opacity)

            ZStack {
                LottieView(animation: .named("complete"))
                    .playbackMode(playbackMode)
                    .frame(width: 250, height: 250)
                
                Text("Submitted!")
                    .font(.title)
                    .fontWeight(.bold)
                    .offset(y: 110)
            }
            .padding(.bottom, 25)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 25))
            .transition(.scale(scale: 0.5).combined(with: .opacity))
        }
        .onAppear {
            playbackMode = .playing(.toProgress(1, loopMode: .playOnce))
        }
    }
}
