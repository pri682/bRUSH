import Foundation

struct LeaderboardEntry: Identifiable, Hashable {
    let id: String
    let uid: String
    let displayName: String
    let handle: String
    let gold: Int
    let silver: Int
    let bronze: Int
    let submittedAt: Date   // tie breaker
    
    var points: Int { gold * 3 + silver * 2 + bronze }
    
    init(
        uid: String,
        displayName: String,
        handle: String,
        gold: Int,
        silver: Int,
        bronze: Int,
        submittedAt: Date = Date()
    ) {
        self.uid = uid
        self.id = uid
        self.displayName = displayName
        self.handle = handle
        self.gold = gold
        self.silver = silver
        self.bronze = bronze
        self.submittedAt = submittedAt
    }
}
