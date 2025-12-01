import SwiftUI

struct AnimatedMeshGradientBackground: View {
    let width: Int = 4
    let height: Int = 4
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSince1970
            let t1 = t * 0.25
            let t2 = t * 0.33

            let a1x = Float(sin(t1) * 0.25)
            let a1y = Float(cos(t2) * 0.25)
            let a2x = Float(cos(t1 * 0.8) * 0.25)
            let a2y = Float(sin(t2 * 0.9) * 0.25)
            let a3x = Float(sin(t2 * 1.1) * 0.25)
            let a3y = Float(cos(t1 * 0.7) * 0.25)
            let a4x = Float(cos(t2 * 1.2) * 0.25)
            let a4y = Float(sin(t2 * 0.6) * 0.25)

            MeshGradient(
                width: width,
                height: height,
                points: [
                    [0.0, 0.0], [0.33, 0.0], [0.66, 0.0], [1.0, 0.0],
                    [0.0, 0.33],
                    [0.33 + a1x, 0.33 + a1y],
                    [0.66 + a2x, 0.33 + a2y],
                    [1.0, 0.33],
                    [0.0, 0.66],
                    [0.33 + a3x, 0.66 + a3y],
                    [0.66 + a4x, 0.66 + a4y],
                    [1.0, 0.66],
                    [0.0, 1.0], [0.33, 1.0], [0.66, 1.0], [1.0, 1.0]
                ],
                colors: colorScheme == .dark ? darkColors : lightColors
            )
            .blur(radius: 40)
            .scaleEffect(1.6)
            .opacity(0.95)
            .ignoresSafeArea()
        }
    }
    
    private var lightColors: [Color] {
        [
            Color(red: 1.0, green: 0.55, blue: 0.4),
            Color(red: 1.0, green: 0.7, blue: 0.5),
            Color(red: 0.9, green: 0.5, blue: 0.8),
            Color(red: 0.7, green: 0.7, blue: 1.0),
            Color(red: 0.55, green: 0.8, blue: 1.0),
            Color(red: 1.0, green: 0.55, blue: 0.4),
            Color(red: 1.0, green: 0.7, blue: 0.5),
            Color(red: 0.9, green: 0.5, blue: 0.8),
            Color(red: 0.7, green: 0.7, blue: 1.0),
            Color(red: 0.55, green: 0.8, blue: 1.0),
            Color(red: 1.0, green: 0.55, blue: 0.4),
            Color(red: 1.0, green: 0.7, blue: 0.5),
            Color(red: 0.9, green: 0.5, blue: 0.8),
            Color(red: 0.7, green: 0.7, blue: 1.0),
            Color(red: 0.55, green: 0.8, blue: 1.0),
            Color(red: 1.0, green: 0.55, blue: 0.4)
        ]
    }
    
    private var darkColors: [Color] {
        [
            Color(red: 0.4, green: 0.2, blue: 0.1),
            Color(red: 0.5, green: 0.25, blue: 0.15),
            Color(red: 0.3, green: 0.1, blue: 0.3),
            Color(red: 0.1, green: 0.1, blue: 0.4),
            Color(red: 0.1, green: 0.2, blue: 0.4),
            Color(red: 0.4, green: 0.2, blue: 0.1),
            Color(red: 0.5, green: 0.25, blue: 0.15),
            Color(red: 0.3, green: 0.1, blue: 0.3),
            Color(red: 0.1, green: 0.1, blue: 0.4),
            Color(red: 0.1, green: 0.2, blue: 0.4),
            Color(red: 0.4, green: 0.2, blue: 0.1),
            Color(red: 0.5, green: 0.25, blue: 0.15),
            Color(red: 0.3, green: 0.1, blue: 0.3),
            Color(red: 0.1, green: 0.1, blue: 0.4),
            Color(red: 0.1, green: 0.2, blue: 0.4),
            Color(red: 0.4, green: 0.2, blue: 0.1)
        ]
    }
}
