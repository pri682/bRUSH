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
    
    // increased multipliers to feel more rewarding
    var points: Int { gold * 100 + silver * 25 + bronze * 10}
    
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
