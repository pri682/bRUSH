import SwiftUI
import PencilKit

struct DetailView: View {
    let item: Item
    @EnvironmentObject var dataModel: DataModel
    @State private var backgroundImage: UIImage?

    var body: some View {
        Group {
            if item.imageURL == nil || backgroundImage != nil {
                DrawingView(item: item, backgroundImage: backgroundImage) { drawing in
                    updateDrawing(drawing)
                }
            } else {
                ProgressView().onAppear(perform: loadImage)
            }
        }
    }
    
    private func loadImage() {
        guard let url = item.imageURL else { return }
        Task {
            if let data = try? Data(contentsOf: url) {
                self.backgroundImage = UIImage(data: data)
            }
        }
    }
    
    private func updateDrawing(_ drawing: PKDrawing) {
        let data = drawing.dataRepresentation()
        let filename = item.drawingURL?.lastPathComponent ?? (UUID().uuidString + ".drawing")
        
        if let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename) {
            do {
                try data.write(to: fileURL, options: .atomic)
                
                let previewSize = CGRect(x: 0, y: 0, width: 200, height: 200)
                let renderer = UIGraphicsImageRenderer(size: previewSize.size)
                let preview = renderer.image { context in
                    backgroundImage?.draw(in: previewSize)
                    drawing.image(from: previewSize, scale: 2.0).draw(in: previewSize)
                }
                
                dataModel.updateItem(item, withDrawingURL: fileURL, preview: preview)
                
            } catch {
                print("Error updating drawing: \(error)")
            }
        }
    }
}
