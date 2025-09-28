import Foundation
import SwiftUI
import PencilKit
import Combine

@MainActor
class DataModel: ObservableObject {
    
    @Published var items: [Item] = [] {
        didSet { save() }
    }
    
    private static var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("items.json")
    }
    
    init() {
        if load() {
            Task { await loadImageCache() }
        } else {
            loadBundledImages()
        }
    }

    func addItem(_ item: Item) {
        items.insert(item, at: 0)
        if let newItem = items.first {
            Task { await loadImageForItem(newItem) }
        }
    }
    
    func updateItem(_ item: Item, withDrawingURL url: URL, preview: UIImage) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = Item(
                id: item.id,
                imageURL: items[index].imageURL,
                drawingURL: url,
                preview: preview
            )
        }
    }

    func removeItem(_ item: Item) {
        if let index = items.firstIndex(of: item) {
            let itemToRemove = items[index]
            // Safely unwrap imageURL before trying to delete the file
            if let imageURL = itemToRemove.imageURL, FileManager.default.isDeletableFile(atPath: imageURL.path) {
                 try? FileManager.default.removeItem(at: imageURL)
            }
            if let drawingURL = itemToRemove.drawingURL {
                try? FileManager.default.removeItem(at: drawingURL)
            }
            items.remove(at: index)
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: Self.fileURL, options: .atomic)
        } catch { print("Error saving items: \(error.localizedDescription)") }
    }

    private func load() -> Bool {
        do {
            let data = try Data(contentsOf: Self.fileURL)
            items = try JSONDecoder().decode([Item].self, from: data)
            return true
        } catch { return false }
    }

    private func loadBundledImages() { /* Your logic here */ }
    
    private func loadImageCache() async {
        for item in items {
            await loadImageForItem(item)
        }
    }
    
    private func loadImageForItem(_ item: Item) async {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        var background: UIImage? = nil
        if let imageURL = item.imageURL, let data = try? Data(contentsOf: imageURL) {
            background = UIImage(data: data)
        }

        if let drawingURL = item.drawingURL,
           drawingURL.startAccessingSecurityScopedResource(),
           let drawingData = try? Data(contentsOf: drawingURL),
           let drawing = try? PKDrawing(data: drawingData) {
            
            drawingURL.stopAccessingSecurityScopedResource()
            let previewSize = CGRect(x: 0, y: 0, width: 200, height: 200)
            let renderer = UIGraphicsImageRenderer(size: previewSize.size)
            let compositePreview = renderer.image { context in
                background?.draw(in: previewSize)
                drawing.image(from: previewSize, scale: 2.0).draw(in: previewSize)
            }
            items[index].preview = compositePreview
        } else if let background = background {
            items[index].preview = background
        } else {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
            items[index].preview = renderer.image { context in UIColor.white.setFill(); context.fill(CGRect(x: 0, y: 0, width: 200, height: 200)) }
        }
    }
}
