import Foundation

struct FeedItem: Identifiable {
    let id: String
    let userId: String
    let firstName: String
    let displayName: String
    let imageURL: String
    var medalGold: Int
    var medalSilver: Int
    var medalBronze: Int
    
    var didGiveGold: Bool = false
    var didGiveSilver: Bool = false
    var didGiveBronze: Bool = false
    
    let date: String
    let createdAt: Date?
    
    let lastName: String
    let email: String
    let avatarType: String
    let avatarBackground: String?
    let avatarFace: String?
    let avatarBody: String?
    let avatarShirt: String?
    let avatarEyes: String?
    let avatarMouth: String?
    let avatarHair: String?
    let avatarFacialHair: String?
    let goldMedalsAccumulated: Int
    let silverMedalsAccumulated: Int
    let bronzeMedalsAccumulated: Int
    let goldMedalsAwarded: Int
    let silverMedalsAwarded: Int
    let bronzeMedalsAwarded: Int
    let totalDrawingCount: Int
    let streakCount: Int
    let memberSince: Date
    let lastCompletedDate: Date?

    var profileSystemImageName: String { "person.circle.fill" }
}
