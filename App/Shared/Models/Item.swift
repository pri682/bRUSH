import SwiftUI

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    let url: URL          // URL for the saved JPG image
    let prompt: String    // The prompt used for the drawing
    let date: Date        // The date the drawing was saved
    var image: UIImage?   // In-memory cache for the loaded image

    // Add the new properties to the CodingKeys so they get saved to JSON.
    enum CodingKeys: String, CodingKey {
        case id, url, prompt, date
    }

    // Update the initializer to include the new properties.
    init(id: UUID = UUID(), url: URL, prompt: String, date: Date, image: UIImage? = nil) {
        self.id = id
        self.url = url
        self.prompt = prompt
        self.date = date
        self.image = image
    }

    static func ==(lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }
}
