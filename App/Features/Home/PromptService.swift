import Foundation

final class PromptService {
    static let shared = PromptService()
    private init() {}

    func fetchPrompt() async throws -> String {
        guard let url = URL(string: "https://generatedailyprompt-loni6woi4a-uc.a.run.app") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(PromptResponse.self, from: data)

        return decoded.prompt
    }
}

struct PromptResponse: Codable {
    let success: Bool
    let prompt: String
}


