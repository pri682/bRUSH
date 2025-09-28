import SwiftUI
import PencilKit

struct DrawingView: View {
    var image: Image
    @State private var showingAlert = false
    @State private var pkCanvasView = PKCanvasView()
    @State private var isSharing = false
    @State private var isBackgroundHiding = false
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
                .shadow(color: Color(red: 0.8, green: 0.8, blue: 0.8, opacity: 0.5), radius: 8)
            
            image
                .resizable()
                .scaledToFit()
                .opacity(isBackgroundHiding ? 0 : 0.3)
            
            GeometryReader { geo in
                PKCanvas(canvasView: $pkCanvasView)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .cornerRadius(20)
                
                VStack(alignment: .trailing) {
                    HStack {
                        Button {
                            isBackgroundHiding.toggle()
                        } label: {
                            Image(systemName: isBackgroundHiding ? "eye" : "eye.slash")
                        }
                        .frame(width: 30, height: 30)
                        .padding(10)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                        
                        Spacer()
                        
                        Button(action: shareDrawing) {
                            Image(systemName: "square.and.arrow.up")
                        }.sheet(isPresented: $isSharing) {
                            let image = pkCanvasView.drawing.image(from: pkCanvasView.bounds, scale: displayScale)
                            ShareSheet(
                                activityItems: [image],
                                excludedActivityTypes: [])
                        }
                        .frame(width: 30, height: 30)
                        .padding(10)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                    }
                    .padding(20)
                }
            }
        }
        .padding(50)
    }
    
    func shareDrawing() {
        isSharing = true
        NotificationManager.shared.clearBadge()

        // Reset deadline to tomorrow at 8 PM
        if let newDeadline = Calendar.current.date(
            bySettingHour: 20,
            minute: 0,
            second: 0,
            of: Date().addingTimeInterval(86400)) {
            
            UserDefaults.standard.set(newDeadline, forKey: "doodleDeadline")
        }

        // Reschedule tomorrow’s notifications (24h + 12h reminders)
        NotificationManager.shared.scheduleDailyReminders(hour: 20, minute: 0)
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView(image: Image("frames"))
    }
}

