import SwiftUI

struct AnimatedMeshGradientBackground: View {
    let width: Int = 3
    let height: Int = 3

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince1970
            // Subtle oscillation offsets for animation
            let offsetX1 = Float(sin(time * 0.8) * 0.08)
            let offsetY1 = Float(cos(time * 0.6) * 0.08)
            let offsetX2 = Float(sin(time * 0.5) * 0.05)
            let offsetY2 = Float(cos(time * 0.7) * 0.05)
            
            MeshGradient(
                width: width,
                height: height,
                points: [
                    [0.0, 0.0],
                    [0.5 + offsetX1, 0.0 + offsetY1],
                    [1.0, 0.0],
                    [0.0, 0.5 + offsetY2],
                    [0.5 + offsetX2, 0.5 + offsetY2],
                    [1.0, 0.5],
                    [0.0, 1.0],
                    [0.5 + offsetX1, 1.0 + offsetY1],
                    [1.0, 1.0]
                ],
                colors: [
                    Color(red: 1.0, green: 0.7, blue: 0.55).opacity(0.6), // soft peach
                    Color(red: 1.0, green: 0.6, blue: 0.5).opacity(0.5),  // muted coral
                    Color(red: 1.0, green: 0.5, blue: 0.45).opacity(0.45), // gentle red
                    Color(red: 1.0, green: 0.65, blue: 0.55).opacity(0.5), // warm tone
                    Color(red: 1.0, green: 0.6, blue: 0.5).opacity(0.45),
                    Color(red: 1.0, green: 0.55, blue: 0.45).opacity(0.4),
                    Color.white.opacity(0.0), Color.white.opacity(0.0), Color.white.opacity(0.0) // fade to white at bottom
                ]
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    AnimatedMeshGradientBackground()
}
