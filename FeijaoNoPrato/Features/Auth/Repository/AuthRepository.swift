// AuthRepository.swift
// Replaces data/repository/login/AuthRepository.kt

import Foundation

final class AuthRepository {

    private let client: NetworkClient
    private let authPreferences: AuthPreferences
    private let appPreferences: AppPreferences

    init(client: NetworkClient, authPreferences: AuthPreferences, appPreferences: AppPreferences) {
        self.client = client
        self.authPreferences = authPreferences
        self.appPreferences = appPreferences
    }

    func requestAccessCode(email: String) async throws -> Bool {
        // TODO: implement — mirrors RequestAccessCodeUseCase
        return false
    }

    func login(email: String, password: String) async throws -> Bool {
        // TODO: implement — mirrors LoginUseCase
        return false
    }

    func registerRespondente(nome: String, email: String, nascimento: String) async throws -> RegisterRespondenteResult {
        // TODO: implement — mirrors RegisterRespondenteUseCase
        return .success
    }

    func logout() {
        authPreferences.clearAll()
        appPreferences.clearAll()
    }
}

enum RegisterRespondenteResult {
    case success
    case emailAlreadyExists
    case unknownError
}
