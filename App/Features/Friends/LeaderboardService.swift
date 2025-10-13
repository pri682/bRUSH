import Foundation

protocol LeaderboardService {
    func fetchLeaderboard(for date: Date) async throws -> [LeaderboardEntry]
}

final class FriendsLeaderboardServiceStub: LeaderboardService {
    func fetchLeaderboard(for date: Date) async throws -> [LeaderboardEntry] {
        // will replace with Firebase users later
        return [
            LeaderboardEntry(
                userId: "1",
                displayName: "Ted",
                handle: "@grumpyoldman",
                gold: 3, silver: 2, bronze: 1,
                submittedAt: Date()
            ),
            LeaderboardEntry(
                userId: "2",
                displayName: "Aaron",
                handle: "@lunchalone",
                gold: 1, silver: 2, bronze: 4,
                submittedAt: Date().addingTimeInterval(-600)
            )
        ]
    }
}
