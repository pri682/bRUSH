import SwiftUI
import Lottie

struct CustomExportAnimation: View {
    let progress: Double
    @State private var playbackMode: LottiePlaybackMode = .paused

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                // Lottie animation (same pattern as your working "fire" one)
                LottieView(animation: .named("generating"))
                    .playbackMode(playbackMode)
                    .frame(width: 320, height: 320)

                // Progress text
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText(value: progress * 100))
                    .animation(.easeInOut, value: progress)

                // Label
                Text("Generating Video")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .onAppear {
            playbackMode = .playing(.toProgress(1, loopMode: .loop))
        }
    }
}
