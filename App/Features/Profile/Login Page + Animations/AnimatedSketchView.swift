import SwiftUI

struct AnimatedSketchView: View {
    let imageNames = [
        "boat","icecream","sun","love","rain","test_plane",
        "burger","soda","boot","banana","home","cat","giraffe",
        "dog","sunglasses","plant","hand","dove","casino","console",
        "ball","football","laugh", "bike", "rainbow", "donut", "brush",
        "pencil", "flower", "sloth", "fire", "frog", "badge", "drumstick",
        "idea", "fork", "skincare", "star", "tree", "wind", "tucan", "bird",
        "moon", "trophy", "pizza", "flash", "dino", "car", "diamond", "roller",
        "bucket", "snowman", "chick", "brain", "pray", "bee", "rocket", "dolphin",
        "drum", "trumpet", "camera", "cafe", "summer", "zzz", "lovehands", "planetring",
        "earth", "helicopter"
        
    ]
    
    let iconSize: CGFloat = 40
    let rowSpacing: CGFloat = 8
    let colSpacing: CGFloat = 8
    let fadeInDuration: TimeInterval = 0.3
    let maxRecent = 15 // # of items we spawn before we can repeat an icon
    
    @State private var sketches: [Sketch] = []
    @State private var canvasSize: CGSize = .zero
    @State private var cancelAnimation = false
    // Added this since I wanted to not have duplicate icons next to each other...
    @State private var recentIcons: [String] = []
    
    
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
                        .colorMultiply(.white)
                        .animation(.easeInOut(duration: fadeInDuration), value: sketch.opacity)
                }
            }
            .onAppear {
                canvasSize = geometry.size
                cancelAnimation = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // how long we wait before the fade in (1 second)
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
        let totalCols = max(1, Int((canvasSize.width + colSpacing) / (iconSize + colSpacing)))
        let totalRows = max(1, Int((canvasSize.height - rowSpacing) / (iconSize + rowSpacing)))
        
        var currentCol = 0
        var currentRow = 0
        
        func drawNextIcon() {
            guard !cancelAnimation else { return }
            guard currentRow < totalRows else { return }

            let actualColSpacing = (canvasSize.width - CGFloat(totalCols) * iconSize) / CGFloat(max(totalCols - 1, 1))
            let actualRowSpacing = (canvasSize.height - CGFloat(totalRows) * iconSize) / CGFloat(max(totalRows - 1, 1))

            let x = CGFloat(currentCol) * (iconSize + actualColSpacing) + iconSize / 2
            let y = CGFloat(currentRow) * (iconSize + actualRowSpacing) + iconSize / 2

            let imageName = getNonRepeatingIcon()
            
            let sketch = Sketch(
                imageName: imageName,
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
            
            // Move to next grid position
            currentCol += 1
            if currentCol >= totalCols {
                currentCol = 0
                currentRow += 1
            }
            
            // Keep drawing next icon after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                drawNextIcon()
            }
        }
        
        drawNextIcon()
    }
    
    // Non-repeating random icon picker
    private func getNonRepeatingIcon() -> String {
        var available = imageNames.filter { !recentIcons.contains($0) }
        if available.isEmpty {
            available = imageNames // reset if all were used recently
            recentIcons.removeAll()
        }
        let chosen = available.randomElement() ?? "test_plane"
        recentIcons.append(chosen)
        
        // Keep only last 15
        if recentIcons.count > maxRecent {
            recentIcons.removeFirst(recentIcons.count - maxRecent)
        }

        
        return chosen
    }
}
