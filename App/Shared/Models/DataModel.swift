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
        if load() {
            Task { await loadImageCache() }
        }
    }

    /// Adds a new item to the collection.
    func addItem(_ item: Item) {
        items.insert(item, at: 0)
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
        } catch { return false }
    }
    
    private func loadImageCache() async {
        for i in items.indices {
            let url = items[i].url
            guard url.startAccessingSecurityScopedResource() else { continue }
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                items[i].image = image
            }
            url.stopAccessingSecurityScopedResource()
        }
    }
}
