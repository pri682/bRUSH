import Foundation

enum AvatarType: String, CaseIterable, Codable {
    case fun = "fun"
    case personal = "personal"
    
    var displayName: String {
        switch self {
        case .fun: return "Fun"
        case .personal: return "Personal"
        }
    }
}

struct AvatarParts: Codable, Equatable {
    var avatarType: AvatarType
    var background: String
    var body: String?
    var shirt: String?
    var eyes: String?
    var mouth: String?
    var hair: String?
    
    // For fun avatars (alien) - these map to the old face/eyes/mouth/hair system
    var face: String? {
        get { body } // Map body to face for fun avatars
        set { body = newValue }
    }
    
    // Default avatar - empty body
    static let `default` = AvatarParts(
        avatarType: .personal,
        background: "background_1",
        body: nil,
        shirt: nil,
        eyes: nil,
        mouth: nil,
        hair: nil
    )
}

// Available avatar options
struct AvatarOptions {
    // Personal avatar options (human)
    static let personalBackgrounds = (1...21).map { "background_\($0)" }
    static let personalBodies = (1...7).map { "body_\($0)" }
    static let personalShirts = (1...16).map { "shirt_\($0)" }
    static let personalEyes = (1...7).map { "eyes_\($0)" }
    static let personalMouths = (1...7).map { "mouth_\($0)" }
    static let personalHairs = (1...56).map { "hair_\($0)" } // hair one to 56, as an array

    
    // Fun avatar options (alien) - using actual fun_ prefixed files
    static let funBackgrounds = (1...21).map { "background_\($0)" }
    static let funFaces = (1...16).map { "fun_face_\($0)" }
    static let funEyes = (1...10).map { "fun_eyes_\($0)" }
    static let funMouths = (1...11).map { "fun_mouth_\($0)" }
    static let funHairs = (1...6).map { "fun_hair_\($0)" }
    
    // Legacy support - these will be deprecated
    static let backgrounds = personalBackgrounds
    static let bodies = personalBodies
    static let shirts = personalShirts
    static let eyes = personalEyes
    static let mouths = personalMouths
    static let hairs = personalHairs
}
