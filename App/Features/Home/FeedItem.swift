import Foundation

struct FeedItem: Identifiable {
    let id: String
    let userId: String
    let firstName: String
    let displayName: String
    let imageURL: String
    let medalGold: Int
    let medalSilver: Int
    let medalBronze: Int
    let date: String
    let createdAt: Date?
    
    let lastName: String
    let email: String
    let avatarType: String
    let avatarBackground: String?
    let avatarBody: String?
    let avatarShirt: String?
    let avatarEyes: String?
    let avatarMouth: String?
    let avatarHair: String?
    let goldMedalsAccumulated: Int
    let silverMedalsAccumulated: Int
    let bronzeMedalsAccumulated: Int
    let goldMedalsAwarded: Int
    let silverMedalsAwarded: Int
    let bronzeMedalsAwarded: Int
    let totalDrawingCount: Int
    let streakCount: Int
    let memberSince: Date

    var profileSystemImageName: String { "person.circle.fill" }
}
