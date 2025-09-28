import SwiftUI
import PencilKit

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    var imageURL: URL?      // URL for the background image (now optional)
    var drawingURL: URL?   // URL for the saved PKDrawing file
    var preview: UIImage?  // In-memory preview image for the grid

    // The 'preview' property is for in-memory use only and should not be saved to JSON.
    enum CodingKeys: String, CodingKey {
        case id, imageURL, drawingURL
    }

    init(id: UUID = UUID(), imageURL: URL?, drawingURL: URL?, preview: UIImage? = nil) {
        self.id = id
        self.imageURL = imageURL
        self.drawingURL = drawingURL
        self.preview = preview
    }

    static func ==(lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }
}
