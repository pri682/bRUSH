import SwiftUI
import PencilKit

struct DrawingView: View {
    // onSave now provides the URL of the saved JPG and the UIImage for the preview cache
    let onSave: (URL, UIImage) -> Void
    
    @State private var pkCanvasView = PKCanvasView()
    @Environment(\.dismiss) var dismiss
    @Environment(\.displayScale) var displayScale
    
    // State to track whether undo/redo is available
    @State private var canUndo = false
    @State private var canRedo = false
    
    // State for the selected canvas theme, defaulting to a white color
    @State private var selectedTheme: CanvasTheme = .color(.white)
    // State to manage the color for the ColorPicker
    @State private var customColor: Color = .white
    // State to present the theme picker as a modern sheet
    @State private var isThemePickerPresented = false

    // Enum to define the available canvas themes
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
        "notebook",
        "chalkboard",
        "canvas",
        "stickynote",
        "bedroomwall"
    ]

    var body: some View {
        Color(uiColor: .systemGray6)
            .ignoresSafeArea()
            .overlay(
                ZStack(alignment: .topLeading) {
                    PKCanvas(canvasView: $pkCanvasView, onDrawingChanged: updateUndoRedoState)
                    
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        HStack {
                            // Undo/Redo Buttons
                            HStack {
                                Button { pkCanvasView.undoManager?.undo(); updateUndoRedoState() } label: { Image(systemName: "arrow.uturn.backward").font(.title2) }.disabled(!canUndo)
                                Divider().frame(height: 20)
                                Button { pkCanvasView.undoManager?.redo(); updateUndoRedoState() } label: { Image(systemName: "arrow.uturn.forward").font(.title2) }.disabled(!canRedo)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(Capsule().fill(.white).shadow(radius: 2))
                            
                            Spacer()

                            // Right-side buttons
                            HStack(spacing: 16) {
                                // MARK: Theme Button with modern .sheet presentation
                                Button {
                                    isThemePickerPresented = true
                                } label: {
                                    Image(systemName: "paintpalette")
                                        .font(.title3)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(.white).shadow(radius: 2))
                                }
                                .sheet(isPresented: $isThemePickerPresented) {
                                    themePickerView
                                }
                                
                                // MARK: Prompt Button
                                Button {
                                    // Later: show drawing prompt
                                } label: {
                                    Image(systemName: "lightbulb")
                                        .font(.title3)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(.white).shadow(radius: 2))
                                }
                            }
                        }
                        .foregroundColor(.accentColor)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    }
                }
                .background(canvasBackground)
                .cornerRadius(34)
                .shadow(radius: 5)
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
            )
            .onAppear(perform: setupCanvas)
            .onChange(of: customColor) { selectedTheme = .color(customColor) }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done") { saveDrawingAsImage(); dismiss() } }
            }
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Subviews

    // A modern, form-based view for the theme picker sheet
    private var themePickerView: some View {
        NavigationView {
            Form {
                Section(header: Text("Color")) {
                    ColorPicker("Custom Color", selection: $customColor, supportsOpacity: false)
                }
                
                Section(header: Text("Textures")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(textureAssets, id: \.self) { assetName in
                            Button {
                                selectedTheme = .texture(assetName)
                                isThemePickerPresented = false
                            } label: {
                                VStack {
                                    Image(assetName)
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
            .navigationTitle("Canvas Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { isThemePickerPresented = false }
                }
            }
        }
    }
    
    @ViewBuilder
    private var canvasBackground: some View {
        switch selectedTheme {
        case .color(let color):
            color
        case .texture(let name):
            if UIImage(named: name) != nil {
                Image(name).resizable().scaledToFill()
            } else {
                Color.white // Fallback if texture is not found
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
        canUndo = pkCanvasView.undoManager?.canUndo ?? false
        canRedo = pkCanvasView.undoManager?.canRedo ?? false
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
        let canvasSize = pkCanvasView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { context in
            if let backgroundImage = selectedTheme.getBackgroundImage(size: canvasSize) {
                backgroundImage.draw(in: CGRect(origin: .zero, size: canvasSize))
            } else {
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: canvasSize))
            }
            let drawingImage = pkCanvasView.drawing.image(from: pkCanvasView.bounds, scale: displayScale)
            drawingImage.draw(in: CGRect(origin: .zero, size: canvasSize))
        }
    }
}

// MARK: - Helpers

extension Color {
    func toUIColor() -> UIColor { UIColor(self) }
}

extension String {
    var displayName: String {
        self.components(separatedBy: "/").last?.capitalized ?? "Texture"
    }
}
