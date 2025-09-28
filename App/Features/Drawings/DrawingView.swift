import SwiftUI
import PencilKit

struct DrawingView: View {
    // Optional item and background for handling both new and existing drawings
    var item: Item?
    var backgroundImage: UIImage?
    // The onSave closure now only needs to pass back the final drawing
    let onSave: (PKDrawing) -> Void
    
    @State private var pkCanvasView = PKCanvasView()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Display background image if one exists
            if let backgroundImage = backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.3)
            }
            
            // The PKCanvas now relies on the built-in tool picker
            PKCanvas(canvasView: $pkCanvasView)
        }
        .onAppear(perform: loadDrawing)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) { Button("Done") {
                onSave(pkCanvasView.drawing)
                dismiss()
            } }
        }
    }
    
    private func loadDrawing() {
        // Load existing strokes if an item was passed in
        if let drawingURL = item?.drawingURL {
            drawingURL.startAccessingSecurityScopedResource()
            if let data = try? Data(contentsOf: drawingURL),
               let drawing = try? PKDrawing(data: data) {
                pkCanvasView.drawing = drawing
            }
            drawingURL.stopAccessingSecurityScopedResource()
        }
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DrawingView(onSave: { _ in })
        }
    }
}
