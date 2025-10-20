import SwiftUI

struct ShredderView: View {
    let image: UIImage
    let onFinished: () -> Void
    
    private let sliceCount = 10
    @State private var slices: [ShredderSlice] = []
    @State private var hasStartedAnimation = false
    
    struct ShredderSlice: Identifiable {
        let id = UUID()
        let image: UIImage
        
        // Animation properties
        var delay: Double
        var xOffset: CGFloat
        var yOffset: CGFloat
        var rotation: Double
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(slices) { slice in
                    Image(uiImage: slice.image)
                        .resizable()
                        .scaledToFit()
                        .offset(x: slice.xOffset, y: slice.yOffset)
                        .rotation3DEffect(
                            .degrees(slice.rotation),
                            axis: (x: Double.random(in: -1...1), y: Double.random(in: -1...1), z: 0)
                        )
                        .animation(.easeOut(duration: 1.5).delay(slice.delay), value: slice.rotation)
                }
            }
            .onAppear {
                setupAndAnimate(size: geo.size)
            }
            .clipped()
        }
    }
    
    private func setupAndAnimate(size: CGSize) {
        guard !hasStartedAnimation, let cgImage = image.cgImage else { return }
        
        let totalWidth = CGFloat(cgImage.width)
        let sliceWidth = totalWidth / CGFloat(sliceCount)
        let totalHeight = CGFloat(cgImage.height)
        
        for i in 0..<sliceCount {
            let cropRect = CGRect(x: CGFloat(i) * sliceWidth, y: 0, width: sliceWidth, height: totalHeight)
            if let croppedCgImage = cgImage.cropping(to: cropRect) {
                let sliceImage = UIImage(cgImage: croppedCgImage)
                let newSlice = ShredderSlice(
                    image: sliceImage,
                    delay: Double(i) * 0.03,
                    xOffset: 0,
                    yOffset: 0,
                    rotation: 0
                )
                self.slices.append(newSlice)
            }
        }
        
        hasStartedAnimation = true
        
        DispatchQueue.main.async {
            for i in 0..<self.slices.count {
                self.slices[i].yOffset = CGFloat.random(in: 400...600)
                self.slices[i].xOffset = CGFloat.random(in: -100...100)
                self.slices[i].rotation = Double.random(in: 360...720) * (i % 2 == 0 ? 1 : -1)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            onFinished()
        }
    }
}

