import SwiftUI
import PencilKit
import Combine

struct DrawingView: View {
    let onSave: (URL, UIImage) -> Void
    
    @State private var pkCanvasView = PKCanvasView()
    @State private var streakManager = StreakManager()
    @Environment(\.dismiss) var dismiss
    @Environment(\.displayScale) var displayScale
    
    @State private var canUndo = false
    @State private var canRedo = false
    @Namespace private var namespace
    
    @State private var selectedTheme: CanvasTheme = .color(.white)
    @State private var customColor: Color = .white
    @State private var isThemePickerPresented = false
    
    private let totalTime: Double = 900
        @State private var timeRemaining: Double = 900
        @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum CanvasTheme: Equatable, Identifiable {
        case color(Color)
        case texture(String)

        var id: String {
            switch self {
            case .color(let color): return "color-\(color.hashValue)"
            case .texture(let name): return "texture-\(name)"
            }
        }
        
        func getBackgroundImage(size: CGSize) -> UIImage? {
            switch self {
            case .color(let color):
                let renderer = UIGraphicsImageRenderer(size: size)
                return renderer.image { $0.cgContext.setFillColor(color.toUIColor().cgColor); $0.cgContext.fill(CGRect(origin: .zero, size: size)) }
            case .texture(let name):
                return UIImage(named: name)
            }
        }
    }
    
    // A list of available texture assets
    private let textureAssets = [
        "notebook", "canvas", "Sticky Note", "scroll",
        "chalkboard", "Classroom", "bathroom", "Wall",
        "Brick", "Grass", "Underwater"
    ]

    var body: some View {
        Color(uiColor: .systemGray6)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 0) {
                    Spacer(minLength: 16)
                    
                    ZStack {
                        canvasView
                            .aspectRatio(9/16, contentMode: .fit)
                            .padding(24)

                        ProgressBorder(
                            progress: CGFloat(timeRemaining / totalTime),
                            cornerRadius: 34,
                            lineWidth: 8
                        )
                        .aspectRatio(16/9, contentMode: .fit)
                        .rotationEffect(.degrees(90), anchor: .center)
                        .scaleEffect(x: -1, y: 1, anchor: .center)
                        .padding(8)
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
            )
            .onAppear(perform: setupCanvas)
            .onChange(of: customColor) { selectedTheme = .color(customColor) }
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer.upstream.connect().cancel()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done") { saveDrawingAsImage();
                    streakManager.markCompletedToday()
                    NotificationManager.shared.resetDailyReminders(hour: 20, minute: 0); dismiss() } }
            }
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
    }

    private var undoRedoControls: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    pkCanvasView.undoManager?.undo()
                    updateUndoRedoState()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!canUndo)
                .font(.title3)
                .frame(width: 44, height: 44)
                .glassEffect()
                .glassEffectID("undoButton", in: namespace)

                if canRedo {
                    Button {
                        pkCanvasView.undoManager?.redo()
                        updateUndoRedoState()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                    }
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .glassEffect()
                    .glassEffectID("redoButton", in: namespace)
                }
            }
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: canRedo)
    }

    private var canvasView: some View {
        ZStack(alignment: .top) {
            PKCanvas(canvasView: $pkCanvasView, onDrawingChanged: updateUndoRedoState)
            
            HStack {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    undoRedoControls
                    
                    Spacer()

                    HStack(spacing: 12) {
                        Button {
                            isThemePickerPresented = true
                        } label: {
                            Image(systemName: "paintpalette")
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .glassEffect(.regular.interactive())
                        }
                        .sheet(isPresented: $isThemePickerPresented) {
                            themePickerView
                                .presentationDetents([.fraction(0.8), .large])
                        }
                        .onChange(of: isThemePickerPresented) { oldValue, newValue in
                            if let picker = (pkCanvasView.delegate as? PKCanvas.Coordinator)?.toolPicker {
                                picker.setVisible(!newValue, forFirstResponder: pkCanvasView)
                            }
                        }
                        
                        Button {
                            // Later: show drawing prompt
                        } label: {
                            Image(systemName: "lightbulb")
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .glassEffect(.regular.interactive())
                        }
                    }
                } else {
                    // iPad Left side: Theme Button
                    Button {
                        isThemePickerPresented = true
                    } label: {
                        Image(systemName: "paintpalette")
                            .font(.title)
                            .frame(width: 54, height: 54)
                            .glassEffect(.regular.interactive())
                    }
                    .sheet(isPresented: $isThemePickerPresented) {
                        themePickerView
                    }
                    
                    Spacer()
                    
                    // iPad Right side: Prompt Button
                    Button {
                        // Later: show drawing prompt
                    } label: {
                        Image(systemName: "lightbulb")
                            .font(.title)
                            .frame(width: 54, height: 54)
                            .glassEffect(.regular.interactive())
                    }
                }
            }
            .foregroundColor(.accentColor)
            .padding(.top, 16)
            .padding(.horizontal, 16)
        }
        .background(canvasBackground)
        .cornerRadius(34)
        .shadow(radius: 5)
    }
    
    // MARK: - Subviews

    private var themePickerView: some View {
        NavigationView {
            Form {
                Section(header: Text("Color").foregroundColor(.primary)) {
                    ColorPicker("Custom Color", selection: $customColor, supportsOpacity: false)
                }
                
                Section(header: Text("Image").foregroundColor(.primary)) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(textureAssets, id: \.self) { assetName in
                            Button {
                                selectedTheme = .texture(assetName)
                                isThemePickerPresented = false
                            } label: {
                                VStack {
                                    Image(assetName: assetName)
                                        .resizable().scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    Text(assetName.displayName)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Custom Backgrounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isThemePickerPresented = false }
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var canvasBackground: some View {
        ZStack {
            switch selectedTheme {
            case .color(let color):
                color
            case .texture:
                Color.white
            }

            if case .texture(let name) = selectedTheme {
                if UIImage(named: name) != nil {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func setupCanvas() {
        pkCanvasView.isOpaque = false
        pkCanvasView.backgroundColor = .clear
        updateUndoRedoState()
    }
    
    private func updateUndoRedoState() {
        withAnimation(.spring()) {
            canUndo = pkCanvasView.undoManager?.canUndo ?? false
            canRedo = pkCanvasView.undoManager?.canRedo ?? false
        }
    }
    
    private func saveDrawingAsImage() {
        let image = createCompositeImage()
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = UUID().uuidString + ".jpg"
        if let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(filename) {
            try? data.write(to: fileURL, options: .atomic)
            onSave(fileURL, image)
        }
    }
    
    private func createCompositeImage() -> UIImage {
        let canvasBounds = pkCanvasView.bounds
        let renderer = UIGraphicsImageRenderer(size: canvasBounds.size)
        
        return renderer.image { context in
            switch selectedTheme {
            case .color(let color):
                color.toUIColor().setFill()
                context.fill(canvasBounds)
                
            case .texture(let name):
                guard let textureImage = UIImage(named: name) else {
                    UIColor.white.setFill()
                    context.fill(canvasBounds)
                    break
                }
                
                let canvasAspect = canvasBounds.width / canvasBounds.height
                let imageAspect = textureImage.size.width / textureImage.size.height
                
                var drawRect: CGRect
                if canvasAspect > imageAspect {
                    let scaledHeight = canvasBounds.width / imageAspect
                    drawRect = CGRect(x: 0, y: (canvasBounds.height - scaledHeight) / 2.0, width: canvasBounds.width, height: scaledHeight)
                } else {
                    let scaledWidth = canvasBounds.height * imageAspect
                    drawRect = CGRect(x: (canvasBounds.width - scaledWidth) / 2.0, y: 0, width: scaledWidth, height: canvasBounds.height)
                }
                textureImage.draw(in: drawRect)
            }
            
            let drawingImage = pkCanvasView.drawing.image(from: canvasBounds, scale: displayScale)
            drawingImage.draw(in: canvasBounds)
        }
    }
}

struct ProgressBorder: View {
    var progress: CGFloat
    var cornerRadius: CGFloat
    var lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: lineWidth / 2)
                .stroke(Color.accentColor.opacity(0.2), lineWidth: lineWidth)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: lineWidth / 2)
                .trim(from: 0, to: progress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-180), anchor: .center)
                .animation(.linear(duration: 1.0), value: progress)
        }
    }
}

extension Image {
    init(assetName: String) {
        if UIImage(named: assetName) != nil {
            self.init(assetName)
        } else if UIImage(named: assetName.lowercased()) != nil {
            self.init(assetName.lowercased())
        } else {
            self.init(systemName: "exclamationmark.triangle")
        }
    }
}

extension Color {
    func toUIColor() -> UIColor { UIColor(self) }
}

extension String {
    var displayName: String {
        self.capitalized
    }
}
