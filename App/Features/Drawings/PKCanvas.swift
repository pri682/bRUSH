import SwiftUI
import PencilKit

struct PKCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    // This closure will be called whenever the drawing changes.
    let onDrawingChanged: () -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        // Set the coordinator as the delegate to receive drawing change notifications.
        canvasView.delegate = context.coordinator

        // Present a per-instance tool picker (shared(for:) is deprecated in iOS 14)
        let picker = context.coordinator.toolPicker
        picker.setVisible(true, forFirstResponder: canvasView)
        picker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // No update needed.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChanged: onDrawingChanged)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let onDrawingChanged: () -> Void
        let toolPicker = PKToolPicker()

        init(onDrawingChanged: @escaping () -> Void) {
            self.onDrawingChanged = onDrawingChanged
        }
        
        /// This delegate method is called automatically by PencilKit whenever the user draws or erases.
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Notify the parent DrawingView that it needs to update the state of the undo/redo buttons.
            onDrawingChanged()
        }
    }
}
