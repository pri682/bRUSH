import SwiftUI
import PencilKit

struct DrawingView: View {
    var item: Item?
    var backgroundImage: UIImage?
    let onSave: (PKDrawing) -> Void
    
    @State private var pkCanvasView = PKCanvasView()
    @State private var streakManager = StreakManager()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if let backgroundImage = backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.3)
            }
            
            // This wrapper now provides the full-featured toolbar
            PKCanvas(canvasView: $pkCanvasView)
        }
        .onAppear(perform: loadDrawing)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) { Button("Done") {
                onSave(pkCanvasView.drawing)
                
                streakManager.markCompletedToday()
                
                // stop reminders for today
                NotificationManager.shared.clearReminders()

                // save deadline for tomorrow (optional, if you want to track it)
                if let newDeadline = Calendar.current.date(
                    bySettingHour: 20,
                    minute: 0,
                    second: 0,
                    of: Date().addingTimeInterval(86400)
                ) {
                    UserDefaults.standard.set(newDeadline, forKey: "doodleDeadline")
                }

                // reschedule for tomorrow
                NotificationManager.shared.scheduleDailyReminders(hour: 20, minute: 0)
                
                dismiss()
            } }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
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
    }
}
