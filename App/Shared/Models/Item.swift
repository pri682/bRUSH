import SwiftUI

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    var url: URL         // URL for the saved JPG image
    var image: UIImage?  // In-memory cache for the loaded image

    // The 'image' property is for in-memory use only and should not be saved to JSON.
    enum CodingKeys: String, CodingKey {
        case id, url
    }

    init(id: UUID = UUID(), url: URL, image: UIImage? = nil) {
        self.id = id
        self.url = url
        self.image = image
    }

    static func ==(lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }
}
