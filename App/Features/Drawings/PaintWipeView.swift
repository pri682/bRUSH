import SwiftUI

struct PaintWipeView: View {
    let targetFrame: CGRect
    var onFinished: () -> Void
    
    @State private var progress: CGFloat = 0.0
    private let texture = Image("texture")
    
    var body: some View {
        texture
            .resizable()
            .scaledToFill()
            .frame(width: targetFrame.width * 1.5, height: targetFrame.height)
            .mask(
                Rectangle()
                    .frame(width: targetFrame.width * 1.5, height: targetFrame.height * progress)
                    .offset(y: -targetFrame.height * (1 - progress)) // negative offset to start above
            )
            .frame(width: targetFrame.width * 1.5, height: targetFrame.height)
            .position(x: targetFrame.midX, y: targetFrame.midY)
            .zIndex(2) // ensure on top
            .onAppear {
                withAnimation(.easeInOut(duration: 0.75)) {
                    progress = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onFinished()
                }
            }
    }
}

