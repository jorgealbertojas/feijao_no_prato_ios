// GamificacaoRepository.swift
// Replaces pontos/repository/GamificacaoRepository.kt

import Foundation

final class GamificacaoRepository {

    private let appPreferences: AppPreferences

    init(appPreferences: AppPreferences) {
        self.appPreferences = appPreferences
    }

    func getPontuacao() -> PontuacaoUsuario {
        // TODO: load from local + remote — mirrors LoadPontuacaoUseCase
        return PontuacaoUsuario(totalAcumulado: appPreferences.gamificacaoPoints, totalConsumido: 0)
    }

    func addPoints(_ amount: Int) {
        appPreferences.gamificacaoPoints += amount
    }

    func consumePoints(_ amount: Int) {
        appPreferences.gamificacaoPoints = max(0, appPreferences.gamificacaoPoints - amount)
    }

    func clearLocalData() {
        appPreferences.gamificacaoPoints = 0
    }
}
