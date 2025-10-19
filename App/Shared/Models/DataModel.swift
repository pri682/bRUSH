import Foundation
import SwiftUI
import Combine

@MainActor
class DataModel: ObservableObject {
    
    @Published var items: [Item] = [] {
        didSet { save() }
    }
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var fileURL: URL {
        documentsDirectory.appendingPathComponent("items.json")
    }
    
    init() {
        _ = load()
    }

    /// Adds a new item to the collection.
    func addItem(_ item: Item) {
        items.insert(item, at: 0)
    }

    /// Loads a specific image from its file into the in-memory cache.
    func loadImage(for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }),
              items[index].image == nil else {
            return
        }
        
        // Get the filename and construct the full URL at runtime.
        let imageFileName = items[index].imageFileName
        let imageUrl = documentsDirectory.appendingPathComponent(imageFileName)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: imageUrl), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let finalIndex = self.items.firstIndex(where: { $0.id == itemID }) {
                        self.items[finalIndex].image = image
                    }
                }
            }
        }
    }
    
    // MARK: - Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL, options: .atomic)
        } catch { print("Error saving items: \(error.localizedDescription)") }
    }

    private func load() -> Bool {
        do {
            let data = try Data(contentsOf: fileURL)
            items = try JSONDecoder().decode([Item].self, from: data)
            return true
        } catch {
            print("Error loading items: \(error.localizedDescription)")
            return false
        }
    }
}
