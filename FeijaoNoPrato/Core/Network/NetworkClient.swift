// NetworkClient.swift
// Replaces RetrofitManager.kt + ApiClient.kt

import Foundation

final class NetworkClient {

    static let baseURLString = "https://pedibraback.azurewebsites.net/"

    private let session: URLSession
    private let baseURL: URL

    init(baseURLString: String = NetworkClient.baseURLString) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        self.baseURL = URL(string: baseURLString)!
    }

    // POST returning no body (just success/failure by HTTP status)
    func postNoBody<Body: Encodable>(_ path: String, body: Body) async throws -> HTTPURLResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        return http
    }

    func post<Body: Encodable, T: Decodable>(_ path: String, body: Body, type: T.Type) async throws -> (T, HTTPURLResponse) {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return (decoded, http)
    }

    func get<T: Decodable>(_ path: String, type: T.Type) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
