import Foundation

struct LeaderboardEntry: Identifiable, Hashable {
    let profile: UserProfile
    
    var id: String { profile.uid }
    var uid: String { profile.uid }
    
    var fullName: String {
        let name = [profile.firstName, profile.lastName].filter { !$0.isEmpty }.joined(separator: " ")
        return name.isEmpty ? profile.displayName : name
    }
    
    var handle: String { "@\(profile.displayName)" }
    
    var gold: Int { profile.goldMedalsAccumulated }
    var silver: Int { profile.silverMedalsAccumulated }
    var bronze: Int { profile.bronzeMedalsAccumulated }
    
    var points: Int {
        gold * 100 + silver * 25 + bronze * 10
    }
    
    var avatarType: String { profile.avatarType }
    var avatarBackground: String? { profile.avatarBackground }
    var avatarBody: String? { profile.avatarBody }
    var avatarFace: String? { profile.avatarFace }
    var avatarShirt: String? { profile.avatarShirt }
    var avatarEyes: String? { profile.avatarEyes }
    var avatarMouth: String? { profile.avatarMouth }
    var avatarHair: String? { profile.avatarHair }
    var avatarFacialHair: String? { profile.avatarFacialHair }
    
    init(profile: UserProfile) {
        self.profile = profile
    }
}
