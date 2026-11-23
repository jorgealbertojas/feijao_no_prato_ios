// ScreenSectionRepository.swift
// Fetches content from zQuestionario/{modulo}/{secao} with Bearer auth

import Foundation

final class ScreenSectionRepository {

    private let network = NetworkClient()
    private let authPrefs = AuthPreferences()

    func fetchSection(modulo: Int, secao: Int) async throws -> SectionResponse {
        let path = "api/zQuestionario/\(modulo)/\(secao)"
        guard let url = URL(string: NetworkClient.baseURLString + path) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = authPrefs.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(SectionResponse.self, from: data)
    }
}
