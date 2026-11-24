// GamificacaoViewModel.swift
// Replaces pontos/model/GamificacaoViewModel.kt

import Foundation
import Combine

struct PontuacaoState: Equatable {
    var totalAcumulado: Int = 0
    var totalConsumido: Int = 0
    var isLoading: Bool = false
    var ultimoModulo: Int = 0
    var ultimoSessao: Int = 0

    var saldo: Int { totalAcumulado - totalConsumido }
}

@MainActor
final class GamificacaoViewModel: ObservableObject {

    @Published var pontuacao = PontuacaoState()
    @Published var rescuedItems: [Int] = []
    @Published var historico: [PontoAtividade] = []

    private var repository: GamificacaoRepository?

    // Called once from AppNavigation after dependencies are ready
    func setup(repository: GamificacaoRepository) {
        self.repository = repository
        // Show cached values immediately so the UI is not stuck at 0 while the network loads
        aplicarCache(repository.cachedPontuacao())
        Task { await carregarDoBackend() }
    }

    // Sync with backend (async); falls back to local cache on error
    func carregar(repository: GamificacaoRepository? = nil) {
        let repo = repository ?? self.repository
        guard let repo else { return }
        self.repository = repo
        Task { await carregarDoBackend() }
    }

    private func aplicarCache(_ p: PontuacaoUsuario) {
        pontuacao.totalAcumulado = p.totalAcumulado
        pontuacao.totalConsumido = p.totalConsumido
        pontuacao.ultimoModulo   = p.ultimoModulo
        pontuacao.ultimoSessao   = p.ultimoSessao
        rescuedItems             = p.list_rescue
    }

    private func carregarDoBackend() async {
        guard let repository else { return }
        pontuacao.isLoading = true
        let p = await repository.sincronizar()
        pontuacao.totalAcumulado = p.totalAcumulado
        pontuacao.totalConsumido = p.totalConsumido
        pontuacao.ultimoModulo   = p.ultimoModulo
        pontuacao.ultimoSessao   = p.ultimoSessao
        rescuedItems             = p.list_rescue
        historico                = p.historico.sorted { $0.data > $1.data }
        pontuacao.isLoading = false
    }

    func addPoints(_ amount: Int, repository: GamificacaoRepository? = nil) {
        let repo = repository ?? self.repository
        repo?.addPoints(amount)
        pontuacao.totalAcumulado += amount
    }

    func consumePoints(_ amount: Int, repository: GamificacaoRepository? = nil) {
        let repo = repository ?? self.repository
        repo?.consumePoints(amount)
        pontuacao.totalConsumido += amount
    }

    func carregarRescuedItems(repository: GamificacaoRepository? = nil) {
        let repo = repository ?? self.repository
        guard let repo else { return }
        rescuedItems = repo.getRescuedItems()
    }

    @discardableResult
    func registrarRescue(numero: Int, quantidade: Int, repository: GamificacaoRepository? = nil) -> Bool {
        guard pontuacao.saldo >= quantidade else { return false }
        consumePoints(quantidade, repository: repository)
        let repo = repository ?? self.repository
        repo?.addRescuedItem(id: numero)
        if !rescuedItems.contains(numero) {
            rescuedItems.append(numero)
        }
        return true
    }

    // MARK: - Add points (mirrors Android GamificacaoViewModel.adicionarPontos)

    func adicionarPontos(modulo_numero: String, modulo: String, atividade: String, referenciaUnica: String) {
        guard let repository else { return }
        let pontos = getPontos(modulo: modulo, atividade: atividade)
        guard pontos > 0 else { return }
        Task {
            await repository.adicionarPontos(
                modulo_numero: modulo_numero,
                modulo: modulo,
                atividade: atividade,
                pontos: pontos,
                referenciaUnica: referenciaUnica
            )
            pontuacao.totalAcumulado = repository.cachedPontuacao().totalAcumulado
        }
    }

    // Reads point value for (modulo, atividade) pair from bundled gamificacao.json.
    private func getPontos(modulo: String, atividade: String) -> Int {
        guard let url = Bundle.main.url(forResource: "gamificacao", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let atividades = obj["atividades"] as? [[String: Any]] else { return 0 }
        for item in atividades {
            if (item["modulo"] as? String) == modulo && (item["atividade"] as? String) == atividade {
                return (item["pontos"] as? Int) ?? 0
            }
        }
        return 0
    }

    func adicionarBonusIAAoEntrarSessao1(modulo: Int, sessao: Int) { }
}
