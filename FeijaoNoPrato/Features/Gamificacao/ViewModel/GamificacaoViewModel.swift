// GamificacaoViewModel.swift
// Replaces pontos/model/GamificacaoViewModel.kt

import Foundation
import Combine

struct PontuacaoState {
    var totalAcumulado: Int = 0
    var totalConsumido: Int = 0
    var isLoading: Bool = false

    var saldo: Int { totalAcumulado - totalConsumido }
}

@MainActor
final class GamificacaoViewModel: ObservableObject {

    @Published var pontuacaoState = PontuacaoState()

    // Repository is injected at the tab level via AppDependencies;
    // for now it uses defaults so the UI compiles and previews work.
    func loadPontuacao(repository: GamificacaoRepository? = nil) {
        guard let repository else { return }
        let p = repository.getPontuacao()
        pontuacaoState.totalAcumulado = p.totalAcumulado
        pontuacaoState.totalConsumido = p.totalConsumido
    }

    func addPoints(_ amount: Int, repository: GamificacaoRepository? = nil) {
        repository?.addPoints(amount)
        pontuacaoState.totalAcumulado += amount
    }

    func consumePoints(_ amount: Int, repository: GamificacaoRepository? = nil) {
        repository?.consumePoints(amount)
        pontuacaoState.totalConsumido += amount
    }
}
