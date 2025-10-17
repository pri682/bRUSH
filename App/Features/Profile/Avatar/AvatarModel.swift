import Foundation

struct AvatarParts: Codable, Equatable {
    var background: String
    var face: String?
    var eyes: String?
    var mouth: String?
    var hair: String?
    
    // Default avatar - empty face
    static let `default` = AvatarParts(
        background: "background_1",
        face: nil,
        eyes: nil,
        mouth: nil,
        hair: nil
    )
}

// Available avatar options
struct AvatarOptions {
    static let backgrounds = ["background_1", "background_2", "background_3", "background_4" , "background_5" , "background_6", "background_7", "background_8"]
    static let faces = ["face_1", "face_2", "face_3", "face_4", "face_5", "face_6", "face_7", "face_8", "face_9", "face_10", "face_11", "face_12", "face_13", "face_14", "face_15", "face_16"]
    static let eyes = ["eyes_1", "eyes_2", "eyes_3", "eyes_4", "eyes_5", "eyes_6", "eyes_7", "eyes_8", "eyes_9", "eyes_10"]
    static let mouths = ["mouth_1", "mouth_2", "mouth_3", "mouth_4", "mouth_5", "mouth_6", "mouth_7", "mouth_8", "mouth_9", "mouth_10", "mouth_11"]
    static let hairs = ["hair_1", "hair_2", "hair_3", "hair_4", "hair_5", "hair_6"]
}
