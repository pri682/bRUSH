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

    func addItem(_ item: Item) {
        items.insert(item, at: 0)
    }

    func loadImage(for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }),
              items[index].image == nil else {
            return
        }
        
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

    func deleteItems(with ids: Set<UUID>) {
        let filenamesToDelete = items.filter { ids.contains($0.id) }.map { $0.imageFileName }
        items.removeAll { ids.contains($0.id) }
        
        DispatchQueue.global(qos: .background).async {
            for filename in filenamesToDelete {
                let fileURL = self.documentsDirectory.appendingPathComponent(filename)
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
    }

    func deleteItem(with id: UUID) {
        deleteItems(with: [id])
    }
    
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

