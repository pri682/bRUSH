import Foundation

struct LeaderboardEntry: Identifiable, Hashable {
    let id: String
    let uid: String
    let fullName: String
    let handle: String
    let gold: Int
    let silver: Int
    let bronze: Int
    let submittedAt: Date   // tie breaker
    let profileImageURL: String?  // URL to user's profile picture (personal photo)
    // Avatar composition parts (when using generated avatar instead of uploaded photo)
    let avatarType: String? // "personal" | "fun"
    let avatarBackground: String?
    let avatarBody: String?
    let avatarShirt: String?
    let avatarEyes: String?
    let avatarMouth: String?
    let avatarHair: String?
    let avatarFacialHair: String?
    
    // increased multipliers to feel more rewarding
    var points: Int { gold * 100 + silver * 25 + bronze * 10}
    
    init(
        uid: String,
        fullName: String,
        handle: String,
        gold: Int,
        silver: Int,
        bronze: Int,
        submittedAt: Date = Date(),
        profileImageURL: String? = nil,
        avatarType: String? = nil,
        avatarBackground: String? = nil,
        avatarBody: String? = nil,
        avatarShirt: String? = nil,
        avatarEyes: String? = nil,
        avatarMouth: String? = nil,
        avatarHair: String? = nil,
        avatarFacialHair: String? = nil
    ) {
        self.uid = uid
        self.id = uid
        self.fullName = fullName
        self.handle = handle
        self.gold = gold
        self.silver = silver
        self.bronze = bronze
        self.submittedAt = submittedAt
        self.profileImageURL = profileImageURL
        self.avatarType = avatarType
        self.avatarBackground = avatarBackground
        self.avatarBody = avatarBody
        self.avatarShirt = avatarShirt
        self.avatarEyes = avatarEyes
        self.avatarMouth = avatarMouth
        self.avatarHair = avatarHair
        self.avatarFacialHair = avatarFacialHair
    }
}
