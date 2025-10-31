import Foundation

protocol LeaderboardService {
    func fetchLeaderboard(for date: Date) async throws -> [LeaderboardEntry]
}
