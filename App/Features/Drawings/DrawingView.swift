import SwiftUI
import PencilKit

struct DrawingView: View {
    var item: Item?
    var backgroundImage: UIImage?
    let onSave: (PKDrawing) -> Void
    
    @State private var pkCanvasView = PKCanvasView()
    @Environment(\.dismiss) var dismiss
    
    // State to track whether undo/redo is available
    @State private var canUndo = false
    @State private var canRedo = false
    
    var body: some View {
        // A light gray background to make the canvas stand out
        Color(uiColor: .systemGray6)
            .ignoresSafeArea()
            .overlay(
                // This ZStack is the new "mini canvas"
                ZStack(alignment: .top) {
                    // Canvas Background
                    if let backgroundImage = backgroundImage {
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .scaledToFit()
                            .opacity(0.3)
                    }
                    
                    // The PencilKit Canvas
                    PKCanvas(canvasView: $pkCanvasView, onDrawingChanged: updateUndoRedoState)
                    
                    // Undo/Redo buttons overlay, only for iPhone
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        HStack(spacing: 20) {
                            Button {
                                pkCanvasView.undoManager?.undo()
                            } label: {
                                Image(systemName: "arrow.uturn.backward.circle.fill")
                                    .font(.largeTitle)
                            }
                            .disabled(!canUndo) // Button is grayed out if canUndo is false
                            
                            Button {
                                pkCanvasView.undoManager?.redo()
                            } label: {
                                Image(systemName: "arrow.uturn.forward.circle.fill")
                                    .font(.largeTitle)
                            }
                            .disabled(!canRedo) // Button is grayed out if canRedo is false
                        }
                        .foregroundColor(.accentColor)
                        .padding(.top)
                    }
                }
                .background(.white)
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding() // Padding around the mini canvas
            )
        .onAppear(perform: loadDrawing)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) { Button("Done") {
                onSave(pkCanvasView.drawing)
                dismiss()
            } }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
    }
    
    /// This function is called every time a stroke is drawn or erased.
    private func updateUndoRedoState() {
        canUndo = pkCanvasView.undoManager?.canUndo ?? false
        canRedo = pkCanvasView.undoManager?.canRedo ?? false
    }
    
    private func loadDrawing() {
        if let drawingURL = item?.drawingURL {
            drawingURL.startAccessingSecurityScopedResource()
            if let data = try? Data(contentsOf: drawingURL),
               let drawing = try? PKDrawing(data: data) {
                pkCanvasView.drawing = drawing
            }
            drawingURL.stopAccessingSecurityScopedResource()
        }
        // Set the initial state of the undo/redo buttons when the view appears.
        updateUndoRedoState()
    }
}
