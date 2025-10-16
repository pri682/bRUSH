import Foundation

struct AvatarParts: Codable, Equatable {
    var face: String
    var eyes: String
    var mouth: String
    
    // Default avatar
    static let `default` = AvatarParts(
        face: "face_1",
        eyes: "eyes_1",
        mouth: "mouth_1"
    )
}

// Available avatar options
struct AvatarOptions {
    static let faces = ["face_1", "face_2"]
    static let eyes = ["eyes_1", "eyes_2"]
    static let mouths = ["mouth_1", "mouth_2"]
}
