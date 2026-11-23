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
        Task { await carregarDoBackend() }
    }

    // Sync with backend (async); falls back to local cache on error
    func carregar(repository: GamificacaoRepository? = nil) {
        let repo = repository ?? self.repository
        guard let repo else { return }
        self.repository = repo
        Task { await carregarDoBackend() }
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

    func adicionarBonusIAAoEntrarSessao1(modulo: Int, sessao: Int) { }
}
