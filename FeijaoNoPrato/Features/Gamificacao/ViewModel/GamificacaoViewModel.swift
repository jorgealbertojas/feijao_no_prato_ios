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

    func carregar(repository: GamificacaoRepository? = nil) {
        guard let repository else { return }
        let p = repository.getPontuacao()
        pontuacao.totalAcumulado = p.totalAcumulado
        pontuacao.totalConsumido = p.totalConsumido
    }

    func addPoints(_ amount: Int, repository: GamificacaoRepository? = nil) {
        repository?.addPoints(amount)
        pontuacao.totalAcumulado += amount
    }

    func consumePoints(_ amount: Int, repository: GamificacaoRepository? = nil) {
        repository?.consumePoints(amount)
        pontuacao.totalConsumido += amount
    }

    func adicionarBonusIAAoEntrarSessao1(modulo: Int, sessao: Int) {
        // stub — gamification bonus for entering session 1
    }
}
