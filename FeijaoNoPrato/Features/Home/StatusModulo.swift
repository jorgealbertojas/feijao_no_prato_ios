// StatusModulo.swift
// Replaces ModuleStatusResolver.kt + StatusModulo enum

import Foundation

enum StatusModulo {
    case liberado
    case proximaSessao
    case proximaSessaoDisponivel
    case proximaLiberado
    case sessaoConcluida
    case proximaSessaoDisponivelNaoIniciada
    case bloqueado
}

struct ModuleStatusResolver {
    // modulo, moduloAtual: 1-based
    // sessao: 0-based (sectionIndex from SectionItemUi)
    // sessaoAtual: 1-based (from AppPreferences)
    static func resolve(
        modulo: Int,
        sessao: Int,
        moduloAtual: Int,
        sessaoAtual: Int,
        totalDeSessao: Int,
        totalTela: Int,
        totalPaginasSessao: Int,
        moduloServidor: Int,
        sessaoServidor: Int,
        liberarPrimeiraSessaoDoProximoModulo: Bool
    ) -> StatusModulo {

        if modulo < moduloAtual {
            return .liberado
        }

        if modulo == moduloAtual && sessao < (sessaoAtual - 1) {
            return .liberado
        }

        if modulo == moduloAtual && sessao == (sessaoAtual - 1) && totalPaginasSessao > 0 && totalTela >= totalPaginasSessao {
            return .sessaoConcluida
        }

        if modulo == moduloAtual && sessao == (sessaoAtual - 1) && totalPaginasSessao > 0 && totalTela > 0 && totalTela < totalPaginasSessao {
            return .proximaSessaoDisponivel
        }

        if modulo == moduloAtual && sessao == (sessaoAtual - 1) && totalTela == 0 {
            return .proximaSessaoDisponivelNaoIniciada
        }

        if modulo == moduloAtual && sessao == (sessaoAtual - 1) {
            return .proximaSessao
        }

        if liberarPrimeiraSessaoDoProximoModulo && modulo == moduloAtual + 1 && sessao == 0 {
            return .proximaLiberado
        }

        if modulo <= moduloServidor && sessao <= sessaoServidor {
            return .proximaLiberado
        }

        if modulo < moduloServidor {
            return .proximaLiberado
        }

        return .bloqueado
    }
}

// MARK: - Trail position helpers (replaces PosicaoNaTrilha.kt)

let nenhumaPosicao = 0

func indiceGlobalDaPosicao(itens: [SectionItemUi], modulo: Int, sessao: Int) -> Int {
    if let exato = itens.first(where: { $0.moduleIndex == modulo && $0.sessaoDaVez == sessao }) {
        return exato.globalIndex
    }
    return itens
        .filter { vemAntes(modulo: $0.moduleIndex, sessao: $0.sessaoDaVez, moduloRef: modulo, sessaoRef: sessao) }
        .max(by: { $0.globalIndex < $1.globalIndex })?
        .globalIndex ?? nenhumaPosicao
}

private func vemAntes(modulo: Int, sessao: Int, moduloRef: Int, sessaoRef: Int) -> Bool {
    modulo < moduloRef || (modulo == moduloRef && sessao < sessaoRef)
}
