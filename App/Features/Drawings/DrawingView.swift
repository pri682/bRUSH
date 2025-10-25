import SwiftUI
import PencilKit
import Combine
import FirebaseFirestore
import FirebaseAuth

struct DrawingView: View {
    var onSave: (Item) -> Void = { _ in }
    let prompt: String
    
    @State private var pkCanvasView = PKCanvasView()
    @State private var streakManager = StreakManager()
    @Environment(\.dismiss) var dismiss
    @Environment(\.displayScale) var displayScale
    
    @State private var showDoneAlert = false
    @State private var showCancelAlert = false
    @State private var showSubmittedPopup = false
    @State private var hasSubmitted = false
    
    @State private var canUndo = false
    @State private var canRedo = false
    @Namespace private var namespace
    
    @State private var selectedTheme: CanvasTheme = .color(.white)
    @State private var customColor: Color = .white
    @State private var isThemePickerPresented = false
    @State private var isPromptPresented = true
    
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
    
    private let textureAssets = [ "notebook", "canvas", "Sticky Note", "scroll", "chalkboard", "Classroom", "bathroom", "Wall", "Brick", "Grass", "Underwater" ]
    
    private var isFlashing: Bool {
        guard timeRemaining <= 30 else { return false }
        return Int(timeRemaining) % 2 == 0
    }

    private var timerColor: Color {
        if isFlashing { return .white }

        let threeQuarterPoint = totalTime * 3 / 4
        let halfPoint = totalTime / 2
        let quarterPoint = totalTime / 4

        if timeRemaining > threeQuarterPoint {
            return Color(red: 0.65, green: 0.85, blue: 0.45)
        } else if timeRemaining > halfPoint {
            let phaseDuration = threeQuarterPoint - halfPoint
            let progress = (threeQuarterPoint - timeRemaining) / phaseDuration
            return Color(UIColor.blend(
                color1: UIColor(red: 0.65, green: 0.85, blue: 0.45, alpha: 1.0),
                color2: UIColor(red: 1.0, green: 0.85, blue: 0.45, alpha: 1.0),
                ratio: CGFloat(progress)
            ))
        } else if timeRemaining > quarterPoint {
            let phaseDuration = halfPoint - quarterPoint
            let progress = (halfPoint - timeRemaining) / phaseDuration
            return Color(UIColor.blend(
                color1: UIColor(red: 1.0, green: 0.85, blue: 0.45, alpha: 1.0),
                color2: UIColor(red: 1.0, green: 0.55, blue: 0.3, alpha: 1.0),
                ratio: CGFloat(progress)
            ))
        } else {
            let phaseDuration = quarterPoint
            let progress = (quarterPoint - timeRemaining) / phaseDuration
            return Color(UIColor.blend(
                color1: UIColor(red: 1.0, green: 0.55, blue: 0.3, alpha: 1.0),
                color2: UIColor(red: 0.9, green: 0.2, blue: 0.25, alpha: 1.0),
                ratio: CGFloat(progress)
            ))
        }
    }


    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .ignoresSafeArea()
                .overlay(
                    VStack(spacing: 0) {
                        Spacer(minLength: 16)
                        
                        ZStack {
                            ProgressBorder(
                                progress: CGFloat(timeRemaining / totalTime),
                                cornerRadius: 40,
                                lineWidth: 6,
                                color: timerColor
                            )
                            .scaleEffect(x: -1, y: 1)
                            .animation(.linear(duration: 1.0), value: timeRemaining)
                            
                            canvasView
                                .padding(6)
                        }
                        .aspectRatio(9/16, contentMode: .fit)
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 16)
                )
                .onAppear {
                    setupCanvas()
                    hasSubmitted = false
                }
                .onDisappear {
                    timer.upstream.connect().cancel()
                }
                .onChange(of: customColor) { selectedTheme = .color(customColor) }
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        submitDrawing()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showCancelAlert = true }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showDoneAlert = true }
                    }
                }
                .alert("Submit Early?", isPresented: $showDoneAlert) {
                    Button("Submit", role: .destructive) {
                        submitDrawing()
                    }
                    Button("Keep Drawing", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to finish? You won't be able to edit this after submitting.")
                }
                .alert("Cancel Drawing?", isPresented: $showCancelAlert) {
                    Button("Yes, Cancel", role: .destructive) {
                        dismiss()
                    }
                    Button("Keep Drawing", role: .cancel) { }
                } message: {
                    Text("If you cancel, you won't get another chance to draw today. Are you sure?")
                }
                .disabled(showSubmittedPopup)
                .toolbar(.hidden, for: .tabBar)
                .navigationBarBackButtonHidden(true)

            if showSubmittedPopup {
                submittedPopup
                    .zIndex(1)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var undoRedoControls: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                if canUndo {
                    Button {
                        pkCanvasView.undoManager?.undo()
                        updateUndoRedoState()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.interactive())
                    .glassEffectID("undoButton", in: namespace)
                }

                if canRedo {
                    Button {
                        pkCanvasView.undoManager?.redo()
                        updateUndoRedoState()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                    }
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.interactive())
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

                    GlassEffectContainer {
                        HStack(spacing: 12) {
                            Button {
                                isPromptPresented.toggle()
                            } label: {
                                Image(systemName: "lightbulb")
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .glassEffect(.regular.interactive())
                            }
                            .popover(isPresented: $isPromptPresented, arrowEdge: .top) {
                                promptView
                            }
                            
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
                                    .presentationDetents([.fraction(0.8)])
                            }
                            .onChange(of: isThemePickerPresented) { oldValue, newValue in
                                if let picker = (pkCanvasView.delegate as? PKCanvas.Coordinator)?.toolPicker {
                                    picker.setVisible(!newValue, forFirstResponder: pkCanvasView)
                                }
                            }
                        }
                    }
                } else {
                    // iPad Right side: Prompt Button
                    Button {
                        isPromptPresented.toggle()
                    } label: {
                        Image(systemName: "lightbulb")
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .glassEffect(.regular.interactive())
                    }
                    .popover(isPresented: $isPromptPresented, arrowEdge: .top) {
                        promptView
                    }
                    
                    Spacer()
                    
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
                }
            }
            .foregroundColor(.accentColor)
            .padding(.top, 16)
            .padding(.horizontal, 16)
        }
        .background(canvasBackground)
        .cornerRadius(34)
        .onTapGesture {
            if isPromptPresented {
                isPromptPresented = false
            }
        }
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
            .scrollContentBackground(.hidden)
            .navigationTitle("Custom Backgrounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) { isThemePickerPresented = false }
                }
            }
        }
    }
    
    @ViewBuilder
    private var promptView: some View {
        let content = Text(prompt)
            .font(.title)
            .fontWeight(.bold)
            .lineSpacing(15)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 25)
            .padding(.horizontal, 40)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.35, blue: 0.2),
                        Color(red: 1.0, green: 0.25, blue: 0.25),
                        Color(red: 0.95, green: 0.4, blue: 0.15)
                    ],
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                )
            )
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
                .frame(width: 500)
                .presentationCompactAdaptation(.popover)
        } else {
            content
                .frame(width: 450)
                .presentationCompactAdaptation(.popover)
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
    
    @ViewBuilder
    private var submittedPopup: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)
            
            Text("Submitted!")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(35)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 25))
        .transition(.scale(scale: 0.5).combined(with: .opacity))
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
    
    private func submitDrawing() {
        hasSubmitted = true
        saveDrawingAsImage()
        
        streakManager.markCompletedToday()
        NotificationManager.shared.resetDailyReminders(hour: 20, minute: 0)
        
        withAnimation(.spring()) {
            showSubmittedPopup = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dismiss()
            }
        }
    }

    private func saveDrawingAsImage() {
        let image = createCompositeImage()
        
        // Local download
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = UUID().uuidString + ".jpg"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL, options: .atomic)
            
            let newItem = Item(
                imageFileName: filename,
                prompt: self.prompt,
                date: Date(),
                image: image
            )
            
            onSave(newItem)
            
        } catch {
            print("Error saving image: \(error)")
        }
        
        // Cloud upload
        DrawingUploader.shared.uploadDrawing(image: image) { result in
                switch result {
                case .success:
                    showSubmittedPopup = true
                case .failure(let error):
                    print("❌ Upload failed: \(error.localizedDescription)")
                }
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
    var color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: lineWidth / 2)
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: lineWidth / 2)
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
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

extension UIColor {
    static func blend(color1: UIColor, color2: UIColor, ratio: CGFloat) -> UIColor {
        let clampedRatio = max(0, min(1, ratio))
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let newRed = r1 * (1 - clampedRatio) + r2 * clampedRatio
        let newGreen = g1 * (1 - clampedRatio) + g2 * clampedRatio
        let newBlue = b1 * (1 - clampedRatio) + b2 * clampedRatio
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

