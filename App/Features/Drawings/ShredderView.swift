import SwiftUI

struct ShredderView: View {
    let image: UIImage
    let onFinished: () -> Void
    
    @State private var slices: [ShredderSlice] = []
    @State private var hasStartedAnimation = false
    
    struct ShredderSlice: Identifiable {
        let id = UUID()
        let image: UIImage
        let width: CGFloat
        var delay: Double
        var xOffset: CGFloat
        var yOffset: CGFloat
        var rotation: Double
        var opacity: Double
        var zDepth: CGFloat
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                HStack(spacing: 0) {
                    ForEach(slices) { slice in
                        Image(uiImage: slice.image)
                            .resizable()
                            .frame(width: slice.width)
                            .offset(x: slice.xOffset, y: slice.yOffset)
                            .rotation3DEffect(
                                .degrees(slice.rotation),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .opacity(slice.opacity)
                            .shadow(
                                color: .black.opacity(0.25 + Double(abs(slice.zDepth)) * 0.02),
                                radius: 6 + abs(slice.zDepth) * 0.2,
                                x: 2 + slice.zDepth * 0.1,
                                y: 4 + slice.zDepth * 0.15
                            )
                            .animation(
                                .easeOut(duration: 3.0)
                                    .delay(slice.delay),
                                value: slice.rotation
                            )
                    }
                }
            }
            .onAppear { setupAndAnimate(size: geo.size) }
        }
    }
    
    private func setupAndAnimate(size: CGSize) {
        guard !hasStartedAnimation, let cgImage = image.cgImage else { return }
        
        let totalWidth = CGFloat(cgImage.width)
        let totalHeight = CGFloat(cgImage.height)
        var currentX: CGFloat = 0
        
        let widthPatterns: [CGFloat] = [0.1, 0.05, 0.15, 0.08, 0.12, 0.1, 0.07, 0.13, 0.09, 0.11].shuffled()
        
        for pattern in widthPatterns {
            let sliceWidth = totalWidth * pattern
            let cropRect = CGRect(x: currentX, y: 0, width: sliceWidth, height: totalHeight)
            
            if let croppedCgImage = cgImage.cropping(to: cropRect) {
                let sliceImage = UIImage(cgImage: croppedCgImage)
                slices.append(ShredderSlice(
                    image: sliceImage,
                    width: size.width * pattern,
                    delay: Double.random(in: 0...0.3),
                    xOffset: 0,
                    yOffset: 0,
                    rotation: 0,
                    opacity: 1,
                    zDepth: CGFloat.random(in: -8...8)
                ))
            }
            currentX += sliceWidth
        }
        
        hasStartedAnimation = true
        
        DispatchQueue.main.async {
            for i in slices.indices {
                let baseDelay = slices[i].delay
                
                // 1️⃣ First jerk
                DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        slices[i].yOffset += 15
                    }
                }
                
                // 2️⃣ Second jerk
                DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay + 0.15) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        slices[i].yOffset += 20
                        slices[i].rotation += Double.random(in: -3...3)
                    }
                }
                
                // 3️⃣ Third jerk
                DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay + 0.3) {
                    withAnimation(.easeInOut(duration: 0.12)) {
                        slices[i].yOffset += 25
                        slices[i].rotation += Double.random(in: -3...3)
                    }
                }
                
                // 💥 Final shredding fall
                DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay + 0.45) {
                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 6)) {
                        slices[i].yOffset = size.height + CGFloat.random(in: 120...320)
                        slices[i].rotation = Double.random(in: -25...25)
                        slices[i].opacity = 0
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onFinished()
        }
    }
}
