import Foundation
import SwiftUI
import Combine

@MainActor
class DataModel: ObservableObject {
    
    @Published var items: [Item] = [] {
        didSet { save() }
    }
    
    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private static var fileURL: URL {
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
        let imageUrl = Self.documentsDirectory.appendingPathComponent(imageFileName)
        
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
    
    func deleteItem(with id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            let itemToDelete = items[index]
            items.remove(at: index)
            
            let documentsDirectory = Self.documentsDirectory
            let fileURL = documentsDirectory.appendingPathComponent(itemToDelete.imageFileName)
            
            DispatchQueue.global(qos: .background).async {
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
    }
    
    func deleteItems(with ids: Set<UUID>) {
        let itemsToDelete = items.filter { ids.contains($0.id) }
        items.removeAll { ids.contains($0.id) }
        
        let documentsDirectory = Self.documentsDirectory
        let filenamesToDelete = itemsToDelete.map { $0.imageFileName }
        
        DispatchQueue.global(qos: .background).async {
            for filename in filenamesToDelete {
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                try? FileManager.default.removeItem(at: fileURL)
            }
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
        } catch {
            print("Error loading items: \(error.localizedDescription)")
            return false
        }
    }
}

