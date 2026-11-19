// AuthRepository.swift
// Replaces data/repository/login/AuthRepository.kt

import Foundation

final class AuthRepository {

    private let client: NetworkClient
    let authPreferences: AuthPreferences
    private let appPreferences: AppPreferences

    init(client: NetworkClient, authPreferences: AuthPreferences, appPreferences: AppPreferences) {
        self.client = client
        self.authPreferences = authPreferences
        self.appPreferences = appPreferences
    }

    // POST api/zSistema/gerarNovoCodigoAcesso
    func requestAccessCode(email: String) async throws -> Bool {
        let body = CodigoRequest(email: email)
        let http = try await client.postNoBody("api/zSistema/gerarNovoCodigoAcesso", body: body)
        return (200..<300).contains(http.statusCode)
    }

    // POST api/zSistema/login
    func login(email: String, password: String) async throws -> Bool {
        let body = LoginRequest(email: email, senha: password)
        do {
            let (response, http) = try await client.post(
                "api/zSistema/login",
                body: body,
                type: LoginResponse.self
            )
            guard (200..<300).contains(http.statusCode), !response.Jwt.isEmpty else { return false }
            authPreferences.token = response.Jwt
            authPreferences.isLoggedIn = true
            authPreferences.email = email
            appPreferences.userEmail = email
            return true
        } catch {
            return false
        }
    }

    // POST api/zSistema/cadastrarSeComoRespondente
    func registerRespondente(nome: String, email: String, nascimento: String) async throws -> RegisterRespondenteResult {
        let body = UsuarioRequest(usuario: Usuario(nomeCompleto: nome, email: email, dataNascimento: nascimento))
        let http = try await client.postNoBody("api/zSistema/cadastrarSeComoRespondente", body: body)
        switch http.statusCode {
        case 200..<300: return .success
        case 400, 409: return .emailAlreadyExists
        default: return .unknownError
        }
    }

    func logout() {
        authPreferences.clearAll()
        appPreferences.clearAll()
    }
}

// MARK: - API models (mirrors data/model/*.kt)

private struct CodigoRequest: Encodable { let email: String }
private struct LoginRequest: Encodable { let email: String; let senha: String }
private struct LoginResponse: Decodable { let Jwt: String }
private struct UsuarioRequest: Encodable { let usuario: Usuario }
private struct Usuario: Encodable {
    let nomeCompleto: String?
    let email: String?
    let dataNascimento: String?
}

enum RegisterRespondenteResult {
    case success
    case emailAlreadyExists
    case unknownError
}
