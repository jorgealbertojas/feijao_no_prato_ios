// AuthViewModel.swift
// Replaces viewmodel/AuthViewModel.kt

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let authRepository: AuthRepository
    private let appPreferences: AppPreferences

    init(authRepository: AuthRepository, appPreferences: AppPreferences) {
        self.authRepository = authRepository
        self.appPreferences = appPreferences
    }

    func requestAccessCode(email: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            return try await authRepository.requestAccessCode(email: email)
        } catch {
            errorMessage = "Não foi possível enviar o código. Tente novamente."
            return false
        }
    }

    func login(email: String, code: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            let success = try await authRepository.login(email: email, password: code)
            if success {
                appPreferences.userEmail = email
                authRepository.authPreferences.isLoggedIn = true
                authRepository.authPreferences.email = email
            }
            return success
        } catch {
            errorMessage = "Erro ao fazer login. Tente novamente."
            return false
        }
    }

    func registerRespondente(nome: String, email: String, nascimento: String, dataNascimentoPerfil: String) async -> RegisterRespondenteResult {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await authRepository.registerRespondente(
                nome: nome, email: email, nascimento: nascimento
            )
            if result == .success {
                appPreferences.userName = nome
                appPreferences.userEmail = email
                appPreferences.birthDate = dataNascimentoPerfil
            }
            return result
        } catch {
            errorMessage = "Erro ao cadastrar. Tente novamente."
            return .unknownError
        }
    }

    func logout() {
        authRepository.logout()
    }
}
