import Foundation

struct LeaderboardEntry: Identifiable, Hashable {
    let id = UUID()
    let userId: String
    let displayName: String
    let handle: String
    let gold: Int
    let silver: Int
    let bronze: Int
    let submittedAt: Date   // tie breaker

    var points: Int { gold * 3 + silver * 2 + bronze }
}
