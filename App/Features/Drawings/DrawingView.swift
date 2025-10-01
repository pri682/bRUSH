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
    
    // State for the selected canvas theme
    @State private var selectedTheme: CanvasTheme = .white

    // Enum to define the available canvas themes
    enum CanvasTheme: String, CaseIterable, Identifiable {
        case white = "White"
        case black = "Black"
        case blackboard = "Blackboard"

        var id: String { self.rawValue }

        // The background color for the SwiftUI view
        var backgroundColor: Color {
            switch self {
            case .white:
                return .white
            case .black:
                return .black
            case .blackboard:
                // You can replace this color with an ImageBrush for your texture
                return Color(red: 0.1, green: 0.2, blue: 0.15)
            }
        }
        
        // The UIColor equivalent for saving the image
        var uiColor: UIColor {
            switch self {
            case .white:
                return .white
            case .black:
                return .black
            case .blackboard:
                // This should match the placeholder color above
                return UIColor(red: 0.1, green: 0.2, blue: 0.15, alpha: 1.0)
            }
        }
    }
    
    var body: some View {
        // A light gray background to make the canvas stand out
        Color(uiColor: .systemGray6)
            .ignoresSafeArea()
            .overlay(
                // This ZStack is the new "mini canvas"
                ZStack(alignment: .topLeading) {
                    // The PencilKit Canvas
                    PKCanvas(canvasView: $pkCanvasView, onDrawingChanged: updateUndoRedoState)
                    
                    // Undo/Redo and other buttons overlay, only for iPhone
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        HStack {
                            // Undo/Redo Buttons
                            HStack {
                                Button {
                                    pkCanvasView.undoManager?.undo()
                                    updateUndoRedoState()
                                } label: {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.title2)
                                }
                                .disabled(!canUndo)
                                
                                Divider().frame(height: 20)

                                Button {
                                    pkCanvasView.undoManager?.redo()
                                    updateUndoRedoState()
                                } label: {
                                    Image(systemName: "arrow.uturn.forward")
                                        .font(.title2)
                                }
                                .disabled(!canRedo)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(.white).shadow(radius: 2))
                            
                            Spacer()

                            // Right-side buttons (Theme and Prompt)
                            HStack(spacing: 16) {
                                // MARK: Theme Button
                                Menu {
                                    ForEach(CanvasTheme.allCases) { theme in
                                        Button(theme.rawValue) {
                                            selectedTheme = theme
                                        }
                                    }
                                } label: {
                                    Image(systemName: "paintpalette") // 🎨 art-themed icon
                                        .font(.title3)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(.white).shadow(radius: 2))
                                }
                                
                                // MARK: Prompt Button
                                Button {
                                    // Later: show drawing prompt
                                } label: {
                                    Image(systemName: "lightbulb") // 💡 new icon for prompt
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
                .background(selectedTheme.backgroundColor) // Use the selected theme for the background
                .cornerRadius(34)
                .shadow(radius: 5)
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
            )
            .onAppear(perform: setupCanvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done") {
                    saveDrawingAsImage()
                    dismiss()
                } }
            }
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
    }
    
    private func setupCanvas() {
        // Make the PKCanvasView background transparent so our ZStack background shows through
        pkCanvasView.isOpaque = false
        pkCanvasView.backgroundColor = .clear
        updateUndoRedoState()
    }
    
    /// This function is called every time a stroke is drawn, erased, or undone/redone.
    private func updateUndoRedoState() {
        canUndo = pkCanvasView.undoManager?.canUndo ?? false
        canRedo = pkCanvasView.undoManager?.canRedo ?? false
    }
    
    // MARK: - Saving Logic
    
    /// Creates a flattened JPG image, saves it to a file, and calls the onSave closure.
    private func saveDrawingAsImage() {
        // 1. Create a UIImage from the drawing with the selected background
        let image = createCompositeImage()
        
        // 2. Convert the image to JPG data
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Could not get JPG data.")
            return
        }
        
        // 3. Create a file URL in the documents directory
        let filename = UUID().uuidString + ".jpg"
        if let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(filename) {
            do {
                // 4. Write the data to the file
                try data.write(to: fileURL, options: .atomic)
                
                // 5. Call the onSave closure with the new URL and the generated image
                onSave(fileURL, image)
                
            } catch {
                print("Error saving image file: \(error)")
            }
        }
    }
    
    /// Creates a single UIImage by drawing the strokes onto the selected background.
    private func createCompositeImage() -> UIImage {
        let canvasSize = pkCanvasView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        let finalImage = renderer.image { context in
            // Fill the background with the selected theme color
            // If you use an image asset for a texture, you would draw it here first.
            selectedTheme.uiColor.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))
            
            // Draw the PencilKit strokes on top
            let drawingImage = pkCanvasView.drawing.image(from: pkCanvasView.bounds, scale: displayScale)
            drawingImage.draw(in: CGRect(origin: .zero, size: canvasSize))
        }
        
        return finalImage
    }
}
