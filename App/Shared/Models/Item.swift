import SwiftUI

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    let imageFileName: String
    let prompt: String
    let date: Date
    var image: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, imageFileName, prompt, date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        imageFileName = try container.decode(String.self, forKey: .imageFileName)
        prompt = try container.decode(String.self, forKey: .prompt)
        date = try container.decode(Date.self, forKey: .date)
        self.image = nil
    }

    init(id: UUID = UUID(), imageFileName: String, prompt: String, date: Date, image: UIImage? = nil) {
        self.id = id
        self.imageFileName = imageFileName
        self.prompt = prompt
        self.date = date
        self.image = image
    }

    static func ==(lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }
}
