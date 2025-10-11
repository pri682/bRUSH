import SwiftUI

struct AnimatedSketchView: View {
    let imageNames = [
        "boat","icecream","sun","love","rain","test_plane",
        "burger","soda","boot","banana","home","cat","giraffe",
        "dog","sunglasses","plant","hand","dove","casino","console",
        "ball","football","laugh", "bike", "rainbow", "donut", "brush", "Pencil", "flower",
        "sloth", "fire", "frog", "badge", "drumsticks", "idea", "fork", "skincare", "star", "tree", "wind",
        "tucan", "bird", "moon", "trophie", "pizza", "flash",
    ]
    
    let iconSize: CGFloat = 40
    let rowSpacing: CGFloat = 8
    let colSpacing: CGFloat = 8
    let fadeInDuration: TimeInterval = 0.3
    
    @State private var sketches: [Sketch] = []
    @State private var canvasSize: CGSize = .zero
    @State private var cancelAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                
                ForEach(sketches) { sketch in
                    Image(sketch.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: sketch.size, height: sketch.size)
                        .rotationEffect(.degrees(sketch.rotation))
                        .position(x: sketch.x, y: sketch.y)
                        .opacity(sketch.opacity)
                        .foregroundColor(sketch.color)
                        .animation(.easeInOut(duration: fadeInDuration), value: sketch.opacity)
                }
            }
            .onAppear {
                canvasSize = geometry.size
                cancelAnimation = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if !cancelAnimation {
                        startDrawingIcons()
                    }
                }
            }
            .onDisappear {
                cancelAnimation = true
                sketches.removeAll()
            }
            .onChange(of: geometry.size) { newSize in
                canvasSize = newSize
            }
        }
        .ignoresSafeArea()
    }
    
    private func startDrawingIcons() {
        let totalCols = max(1, Int((canvasSize.width - colSpacing) / (iconSize + colSpacing)))
        let totalRows = max(1, Int((canvasSize.height - rowSpacing) / (iconSize + rowSpacing)))
        
        var currentCol = 0
        var currentRow = 0
        
        func drawNextIcon() {
            guard !cancelAnimation else { return }
            guard currentRow < totalRows else { return } // all icons drawn
            
            let x = CGFloat(currentCol) * (iconSize + colSpacing) + iconSize/2 + colSpacing/2
            let y = CGFloat(currentRow) * (iconSize + rowSpacing) + iconSize/2 + rowSpacing/2
            
            let sketch = Sketch(
                imageName: imageNames.randomElement() ?? "test_plane",
                x: x,
                y: y,
                size: iconSize,
                rotation: Double.random(in: -15...15),
                opacity: 0,
                isFadingOut: false,
                color: .white
            )
            
            sketches.append(sketch)
            
            // Fade in individually
            DispatchQueue.main.async {
                if let index = sketches.firstIndex(where: { $0.id == sketch.id }) {
                    var updated = sketches
                    updated[index].opacity = Double.random(in: 0.12...0.2)
                    sketches = updated
                }
            }
            
            // Move to next position
            currentCol += 1
            if currentCol >= totalCols {
                currentCol = 0
                currentRow += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                drawNextIcon()
            }
        }
        
        drawNextIcon()
    }
}
