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
    
    var body: some View {
        // A light gray background to make the canvas stand out
        Color(uiColor: .systemGray6)
            .ignoresSafeArea()
            .overlay(
                // This ZStack is the new "mini canvas"
                ZStack(alignment: .topLeading) {
                    // The PencilKit Canvas
                    PKCanvas(canvasView: $pkCanvasView, onDrawingChanged: updateUndoRedoState)
                    
                    // Undo/Redo and Info buttons overlay, only for iPhone
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        HStack {
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

                            // MARK: Info Button
                            Button {
                                // Later: show drawing prompt
                            } label: {
                                Image(systemName: "paintpalette") // 🎨 art-themed icon
                                    .font(.title3)
                                    .padding(10)
                                    .background(Circle().fill(.white).shadow(radius: 2))
                            }
                        }
                        .foregroundColor(.accentColor)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    }
                }
                .background(.white)
                .cornerRadius(34)
                .shadow(radius: 5)
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
            )
            .onAppear(perform: updateUndoRedoState)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done") {
                    // The "Done" button now calls the new save function
                    saveDrawingAsImage()
//
//                    // stop reminders for today
//                    NotificationManager.shared.clearReminders()
//
//                    // save deadline for tomorrow (optional, if you want to track it)
//                    if let newDeadline = Calendar.current.date(
//                        bySettingHour: 20,
//                        minute: 0,
//                        second: 0,
//                        of: Date().addingTimeInterval(86400)
//                    ) {
//                        UserDefaults.standard.set(newDeadline, forKey: "doodleDeadline")
//                    }
//
//                    // reschedule for tomorrow
//                    NotificationManager.shared.scheduleDailyReminders(hour: 20, minute: 0)
//
                    dismiss()
                } }
            }
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
    }
    
    /// This function is called every time a stroke is drawn, erased, or undone/redone.
    private func updateUndoRedoState() {
        canUndo = pkCanvasView.undoManager?.canUndo ?? false
        canRedo = pkCanvasView.undoManager?.canRedo ?? false
    }
    
    // MARK: - Saving Logic
    
    /// Creates a flattened JPG image, saves it to a file, and calls the onSave closure.
    private func saveDrawingAsImage() {
        // 1. Create a UIImage from the drawing with a white background
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
    
    /// Creates a single UIImage by drawing the strokes onto a white background.
    private func createCompositeImage() -> UIImage {
        let canvasSize = pkCanvasView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        let finalImage = renderer.image { context in
            // Fill the background with white
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))
            
            // Draw the PencilKit strokes on top
            let drawingImage = pkCanvasView.drawing.image(from: pkCanvasView.bounds, scale: displayScale)
            drawingImage.draw(in: CGRect(origin: .zero, size: canvasSize))
        }
        
        return finalImage
    }
}
