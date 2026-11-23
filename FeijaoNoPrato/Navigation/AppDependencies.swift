// AppDependencies.swift
// Replaces Hilt — dependencies are passed through the environment.

import Foundation
import Combine

@MainActor
final class AppDependencies: ObservableObject {

    // MARK: - Storage
    let authPreferences = AuthPreferences()
    let appPreferences = AppPreferences()

    // MARK: - Network
    let networkClient = NetworkClient()

    // MARK: - Repositories (lazy — created once and reused)
    lazy var authRepository: AuthRepository = AuthRepository(
        client: networkClient,
        authPreferences: authPreferences,
        appPreferences: appPreferences
    )

    lazy var gamificacaoRepository: GamificacaoRepository = GamificacaoRepository(
        appPreferences: appPreferences,
        authPreferences: authPreferences,
        networkClient: networkClient
    )
}
