import SwiftUI

struct AnimatedSketchView: View {
    let sketchCount = 6 // how many floating sketches at once
    let imageName = "test_plane"
    @State private var sketches: [Sketch] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(sketches) { sketch in
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: sketch.size)
                        .rotationEffect(.degrees(sketch.rotation))
                        .opacity(sketch.opacity)
                        .position(x: sketch.x, y: sketch.y)
                        .animation(
                            Animation.easeInOut(duration: sketch.speed)
                                .repeatForever(autoreverses: true),
                            value: sketch.rotation
                        )
                        .onAppear {
                            startAnimation(for: sketch.id, in: geometry.size)
                        }
                }
            }
            .onAppear {
                generateSketches(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Generate Random Sketches
    private func generateSketches(in size: CGSize) {
        sketches = (0..<sketchCount).map { _ in
            Sketch(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 60...140),
                rotation: Double.random(in: 0...360),
                opacity: Double.random(in: 0.05...0.12),
                speed: Double.random(in: 4...8)
            )
        }
    }

    // MARK: - Animate Rotation Randomly
    private func startAnimation(for id: UUID, in size: CGSize) {
        guard let index = sketches.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(Animation.easeInOut(duration: sketches[index].speed).repeatForever(autoreverses: true)) {
            sketches[index] = Sketch(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: sketches[index].size,
                rotation: Double.random(in: 0...360),
                opacity: sketches[index].opacity,
                speed: sketches[index].speed
            )
        }
    }
}
