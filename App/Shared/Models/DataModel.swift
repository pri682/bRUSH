import Foundation
import SwiftUI
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
        _ = load()
    }

    /// Adds a new item to the collection.
    func addItem(_ item: Item) {
        items.insert(item, at: 0)
        // Notify other parts of the app that a new item was created so feeds can update
        NotificationCenter.default.post(name: .didAddItem, object: item)
    }

    /// Loads a specific image from its URL into the in-memory cache.
    func loadImage(for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }),
              items[index].image == nil else {
            return
        }
        
        let itemUrl = items[index].url
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard itemUrl.startAccessingSecurityScopedResource() else { return }
            defer { itemUrl.stopAccessingSecurityScopedResource() }
            
            if let data = try? Data(contentsOf: itemUrl), let image = UIImage(data: data) {
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
            try data.write(to: Self.fileURL, options: .atomic)
        } catch { print("Error saving items: \(error.localizedDescription)") }
    }

    private func load() -> Bool {
        do {
            let data = try Data(contentsOf: Self.fileURL)
            items = try JSONDecoder().decode([Item].self, from: data)
            return true
        } catch {
            print("Error loading items: \(error.localizedDescription)")
            return false
        }
    }
}
