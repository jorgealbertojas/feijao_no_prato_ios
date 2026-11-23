// GamificacaoRepository.swift
// Replaces pontos/repository/GamificacaoRepository.kt

import Foundation

final class GamificacaoRepository {

    private let appPreferences: AppPreferences
    private let authPreferences: AuthPreferences
    private let networkClient: NetworkClient

    private let chave = "pontos_usuario"

    init(appPreferences: AppPreferences, authPreferences: AuthPreferences, networkClient: NetworkClient) {
        self.appPreferences = appPreferences
        self.authPreferences = authPreferences
        self.networkClient = networkClient
    }

    // MARK: - Remote sync

    func sincronizar() async -> PontuacaoUsuario {
        guard let token = authPreferences.token else {
            return cachedPontuacao()
        }
        do {
            let response: ProgressResponse = try await networkClient.getWithAuth(
                "api/zRespondente/resposta/\(chave)",
                bearer: token,
                type: ProgressResponse.self
            )
            if let pontuacao = try? JSONDecoder().decode(PontuacaoUsuario.self, from: Data(response.Valor.utf8)) {
                // persist locally
                appPreferences.gamificacaoPoints = pontuacao.totalAcumulado
                appPreferences.gamificacaoPontosConsumidos = pontuacao.totalConsumido
                appPreferences.rescuedItems = pontuacao.list_rescue
                if pontuacao.ultimoModulo > 0 { appPreferences.ultimoModulo = pontuacao.ultimoModulo }
                if pontuacao.ultimoSessao > 0 { appPreferences.ultimoSessao = pontuacao.ultimoSessao }
                return pontuacao
            }
        } catch {
            // fall through to cached
        }
        return cachedPontuacao()
    }

    // MARK: - Local access

    func cachedPontuacao() -> PontuacaoUsuario {
        PontuacaoUsuario(
            totalAcumulado: appPreferences.gamificacaoPoints,
            totalConsumido: appPreferences.gamificacaoPontosConsumidos,
            ultimoModulo: appPreferences.ultimoModulo,
            ultimoSessao: appPreferences.ultimoSessao,
            list_rescue: appPreferences.rescuedItems
        )
    }

    func addPoints(_ amount: Int) {
        appPreferences.gamificacaoPoints += amount
    }

    func consumePoints(_ amount: Int) {
        appPreferences.gamificacaoPontosConsumidos = max(0, appPreferences.gamificacaoPontosConsumidos - amount)
    }

    func getRescuedItems() -> [Int] {
        appPreferences.rescuedItems
    }

    func addRescuedItem(id: Int) {
        var list = appPreferences.rescuedItems
        if !list.contains(id) {
            list.append(id)
            appPreferences.rescuedItems = list
        }
    }

    func clearLocalData() {
        appPreferences.gamificacaoPoints = 0
        appPreferences.gamificacaoPontosConsumidos = 0
        appPreferences.rescuedItems = []
    }
}
