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
    static let personalBackgrounds = ["background_1", "background_2", "background_3", "background_4" , "background_5" , "background_6", "background_7", "background_8"]
    static let personalBodies = ["body_1", "body_2", "body_3", "body_4", "body_5", "body_6", "body_7"]
    static let personalShirts = ["shirt_1", "shirt_2", "shirt_3", "shirt_4", "shirt_5", "shirt_6", "shirt_7", "shirt_8", "shirt_9", "shirt_10", "shirt_11", "shirt_12", "shirt_13", "shirt_14", "shirt_15", "shirt_16"]
    static let personalEyes = ["eyes_1", "eyes_2", "eyes_3", "eyes_4", "eyes_5", "eyes_6", "eyes_7"]
    static let personalMouths = ["mouth_1", "mouth_2", "mouth_3", "mouth_4", "mouth_5", "mouth_6", "mouth_7"]
    static let personalHairs = (1...56).map { "hair_\($0)" } // hair one to 56, as an array

    
    // Fun avatar options (alien) - using actual fun_ prefixed files
    static let funBackgrounds = ["background_1", "background_2", "background_3", "background_4" , "background_5" , "background_6", "background_7", "background_8"]
    static let funFaces = ["fun_face_1", "fun_face_2", "fun_face_3", "fun_face_4", "fun_face_5", "fun_face_6", "fun_face_7", "fun_face_8", "fun_face_9", "fun_face_10", "fun_face_11", "fun_face_12", "fun_face_13", "fun_face_14", "fun_face_15", "fun_face_16"]
    static let funEyes = ["fun_eyes_1", "fun_eyes_2", "fun_eyes_3", "fun_eyes_4", "fun_eyes_5", "fun_eyes_6", "fun_eyes_7", "fun_eyes_8", "fun_eyes_9", "fun_eyes_10"]
    static let funMouths = ["fun_mouth_1", "fun_mouth_2", "fun_mouth_3", "fun_mouth_4", "fun_mouth_5", "fun_mouth_6", "fun_mouth_7", "fun_mouth_8", "fun_mouth_9", "fun_mouth_10", "fun_mouth_11"]
    static let funHairs = ["fun_hair_1", "fun_hair_2", "fun_hair_3", "fun_hair_4", "fun_hair_5", "fun_hair_6"]
    
    // Legacy support - these will be deprecated
    static let backgrounds = personalBackgrounds
    static let bodies = personalBodies
    static let shirts = personalShirts
    static let eyes = personalEyes
    static let mouths = personalMouths
    static let hairs = personalHairs
}
