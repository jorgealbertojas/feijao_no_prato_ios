// HomeViewModel.swift
// Replaces LevelViewModel + SessionViewModel for the Home screen context

import Foundation
import SwiftUI

// MARK: - Trail item computed state

struct TrailItemState: Identifiable {
    let sectionItem: SectionItemUi
    let imageState: ImageState
    let isClickable: Bool
    let isBlocked: Bool
    let showHereIndicator: Bool
    let showDivider: Bool
    let dividerLabel: String
    let isSpecialModule: Bool

    var id: String { sectionItem.id }

    enum ImageState {
        case completed   // imagem3 — green
        case inProgress  // imagem2 — yellow/orange
        case available   // imagem1 — white
        case locked      // imagem1 dim — gray
    }
}

// MARK: - HomeViewModel

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published
    @Published var levels: [LevelData] = []
    @Published var trailItems: [TrailItemState] = []
    @Published var scrollToGlobalIndex: Int = 0

    // Progress from prefs (refreshed on appear/foreground)
    @Published var moduloAtual: Int = 1
    @Published var sessaoAtual: Int = 1
    @Published var moduloVisual: Int = 1
    @Published var sessaoVisual: Int = 1
    @Published var moduloVisualMax: Int = 0
    @Published var sessaoVisualMax: Int = 0
    @Published var moduloConcluido: Int = 0
    @Published var sessaoConcluida: Int = 0
    @Published var totalTela: Int = 0
    @Published var nivelSalvo: String = ""
    @Published var titleSalvo: String = ""

    // MARK: - Computed card display
    var sessaoTotal: Int {
        sectionItems.first(where: { $0.moduleIndex == moduloAtual })?.totalSectionsInModule ?? 0
    }

    var sessaoPosicao: Float {
        guard sessaoTotal > 0 else { return 0 }
        return Float(sessaoAtual) / Float(sessaoTotal)
    }

    var nivelExibicao: String {
        let secao = sectionItems.first(where: {
            $0.moduleIndex == moduloAtual && $0.sessaoDaVez == sessaoAtual
        })
        return secao?.section.nivel ?? nivelSalvo
    }

    var currentSectionTitle: String {
        let secao = sectionItems.first(where: {
            $0.moduleIndex == moduloAtual && $0.sessaoDaVez == sessaoAtual
        })
        return secao?.section.title ?? titleSalvo
    }

    // MARK: - Private
    private let dataSource = LocalLevelsDataSource()
    private let prefs = AppPreferences()
    private var sectionItems: [SectionItemUi] = []

    // MARK: - Load

    func loadAll() {
        if levels.isEmpty {
            levels = dataSource.loadLevels()
            buildSectionItems()
        }
        loadPrefs()
        recomputeTrail(moduloServidor: 0, sessaoServidor: 0)
    }

    func refreshFromPrefs() {
        loadPrefs()
        recomputeTrail(moduloServidor: 0, sessaoServidor: 0)
    }

    func updateWithGamificacao(moduloServidor: Int, sessaoServidor: Int) {
        recomputeTrail(moduloServidor: moduloServidor, sessaoServidor: sessaoServidor)
    }

    func saveBeforeNavigation(section: SectionItemUi) {
        let modulo = Int(section.section.module) ?? section.moduleIndex
        let sessao = section.sessaoDaVez
        prefs.moduloVisual = modulo
        prefs.sessaoVisual = sessao
        if modulo > prefs.moduloVisualMax || (modulo == prefs.moduloVisualMax && sessao > prefs.sessaoVisualMax) {
            prefs.moduloVisualMax = modulo
            prefs.sessaoVisualMax = sessao
        }
        prefs.nivelAtual = section.section.nivel
        prefs.titleSalvo = section.section.title
        prefs.totalTela = 0
    }

    // MARK: - Private helpers

    private func loadPrefs() {
        moduloAtual = max(1, prefs.moduloAtual)
        sessaoAtual = max(1, prefs.sessaoAtual)
        moduloVisual = prefs.moduloVisual
        sessaoVisual = prefs.sessaoVisual
        moduloVisualMax = prefs.moduloVisualMax
        sessaoVisualMax = prefs.sessaoVisualMax
        moduloConcluido = prefs.moduloConcluido
        sessaoConcluida = prefs.sessaoConcluida
        totalTela = prefs.totalTela
        nivelSalvo = prefs.nivelAtual
        titleSalvo = prefs.titleSalvo
    }

    private func buildSectionItems() {
        var globalIndex = 0
        sectionItems = levels.flatMap { level in
            level.module.enumerated().flatMap { (moduleIdx, module) in
                module.section.enumerated().map { (sectionIdx, section) in
                    globalIndex += 1
                    return SectionItemUi(
                        section: section,
                        moduleIndex: moduleIdx + 1,
                        sectionIndex: sectionIdx,
                        globalIndex: globalIndex,
                        totalSectionsInModule: module.section.count,
                        totalPagesInSection: section.paragraphs?.count ?? 0
                    )
                }
            }
        }
    }

    private func recomputeTrail(moduloServidor: Int, sessaoServidor: Int) {
        guard !sectionItems.isEmpty else { return }

        let totalTelaDaSessaoVisualAtual = max(prefs.getSessionViewedPages(modulo: moduloVisual, sessao: sessaoVisual), totalTela)
        let totalPaginasDaSessaoVisualAtual = max(prefs.getSessionTotalPages(modulo: moduloVisual, sessao: sessaoVisual),
                                                   sectionItems.first(where: { $0.moduleIndex == moduloVisual && $0.sessaoDaVez == sessaoVisual })?.totalPagesInSection ?? 0)

        let iConcluido = indiceGlobalDaPosicao(itens: sectionItems, modulo: moduloConcluido, sessao: sessaoConcluida)
        let iPosicaoAtual = max(1, indiceGlobalDaPosicao(itens: sectionItems, modulo: moduloVisual, sessao: sessaoVisual).nonZero ?? 1)
        let iVisitado = max(iPosicaoAtual, indiceGlobalDaPosicao(itens: sectionItems, modulo: moduloVisualMax, sessao: sessaoVisualMax).nonZero ?? iPosicaoAtual)

        let existeEmAndamento = iVisitado > iConcluido
        let iEmAndamento = existeEmAndamento ? iVisitado : 0

        let iOndeEstou: Int
        if iVisitado > 0 { iOndeEstou = iVisitado }
        else if iConcluido > 0 { iOndeEstou = iConcluido }
        else { iOndeEstou = iPosicaoAtual }

        let iProxima: Int
        if iEmAndamento > 0 { iProxima = min(iEmAndamento + 1, sectionItems.count) }
        else if iConcluido > 0 { iProxima = min(iConcluido + 1, sectionItems.count) }
        else { iProxima = iPosicaoAtual }

        let totalSessoesModuloAtual = sectionItems.first(where: { $0.moduleIndex == moduloAtual })?.totalSectionsInModule ?? 0
        let totalPaginasSessaoAtual = sectionItems.first(where: {
            $0.moduleIndex == moduloAtual && $0.sessaoDaVez == sessaoAtual
        })?.totalPagesInSection ?? 0

        let terminouModuloAtual = totalSessoesModuloAtual > 0 && sessaoAtual >= totalSessoesModuloAtual

        let sessaoVisualAtualFoiFinalizada =
            moduloVisual > 0 && sessaoVisual > 0 &&
            totalPaginasDaSessaoVisualAtual > 0 &&
            totalTelaDaSessaoVisualAtual >= totalPaginasDaSessaoVisualAtual

        scrollToGlobalIndex = iOndeEstou

        var previousModuleGroup = -1
        trailItems = sectionItems.map { item in
            let modIdx = item.moduleIndex
            let secIdx = item.sectionIndex
            let sessao = item.sessaoDaVez

            let totalPaginasSessao = item.totalPagesInSection
            let totalPaginasSessaoAnterior = sectionItems.first(where: { $0.moduleIndex == modIdx && $0.sectionIndex == secIdx - 1 })?.totalPagesInSection ?? 0

            let ehPrimeiraSessaoDoModulo1 = modIdx == 1 && sessao == 1
            let jaAvancouDepoisDaPrimeiraSessao = moduloConcluido > 1 || (moduloConcluido == 1 && sessaoConcluida > 1)
            let ehUltimaSessaoDoModuloAtual = modIdx == moduloAtual && sessaoAtual == item.totalSectionsInModule
            let desbloqueioEspecialFinal = (9...11).contains(modIdx) && ((moduloAtual == 8 && sessaoAtual == 7) || moduloAtual >= 9)

            let statusAtual = ModuleStatusResolver.resolve(
                modulo: modIdx,
                sessao: secIdx,
                moduloAtual: moduloAtual,
                sessaoAtual: sessaoAtual,
                totalDeSessao: totalSessoesModuloAtual,
                totalTela: totalTela,
                totalPaginasSessao: totalPaginasSessao,
                moduloServidor: moduloServidor,
                sessaoServidor: sessaoServidor,
                liberarPrimeiraSessaoDoProximoModulo: ehUltimaSessaoDoModuloAtual
            )

            let statusAnterior = ModuleStatusResolver.resolve(
                modulo: modIdx,
                sessao: secIdx - 1,
                moduloAtual: moduloAtual,
                sessaoAtual: sessaoAtual,
                totalDeSessao: totalSessoesModuloAtual,
                totalTela: totalTela,
                totalPaginasSessao: totalPaginasSessaoAnterior,
                moduloServidor: moduloServidor,
                sessaoServidor: sessaoServidor,
                liberarPrimeiraSessaoDoProximoModulo: ehUltimaSessaoDoModuloAtual
            )

            let estaAntesDaSessaoAtualNoCaminho = iOndeEstou > 0 && item.globalIndex < iOndeEstou
            let sessaoJaPercorridaSemBloqueio = estaAntesDaSessaoAtualNoCaminho || modIdx < moduloAtual || (modIdx == moduloAtual && sessao < sessaoAtual)

            let jaFoiConcluidaVisualmente = iConcluido > 0 && item.globalIndex <= iConcluido
            let jaFoiAlcancadaVisualmente = iVisitado > 0 && item.globalIndex <= iVisitado
            let sessaoAtualTemProgresso = moduloVisual == modIdx && sessaoVisual == sessao && totalTelaDaSessaoVisualAtual > 0
            let deveFicarAmarela = jaFoiAlcancadaVisualmente && !jaFoiConcluidaVisualmente && sessaoAtualTemProgresso
            let isPosicaoVisualAtual = moduloVisual == modIdx && sessaoVisual == sessao && totalTelaDaSessaoVisualAtual > 0
            let isProximaSessaoLiberada = item.globalIndex == iProxima

            let sessaoAtualFoiFinalizadaVisualmente = moduloVisual == modIdx && sessaoVisual == sessao &&
                totalPaginasDaSessaoVisualAtual > 0 && totalTelaDaSessaoVisualAtual >= totalPaginasDaSessaoVisualAtual
            let isSessaoEmAndamento = sessaoAtualTemProgresso && !jaFoiConcluidaVisualmente && !sessaoAtualFoiFinalizadaVisualmente

            let ehPrimeiraSessaoDoProximoModulo = terminouModuloAtual && modIdx == moduloAtual + 1 && sessao == 1
            let sessaoAnteriorConcluida = statusAtual == .proximaLiberado && sessao == sessaoAtual + 1 && statusAnterior == .sessaoConcluida

            let isClickable = ehPrimeiraSessaoDoModulo1 || desbloqueioEspecialFinal || statusAtual != .bloqueado

            let isClickableSeTerminou =
                ehPrimeiraSessaoDoModulo1 ||
                sessaoJaPercorridaSemBloqueio ||
                desbloqueioEspecialFinal ||
                jaFoiConcluidaVisualmente ||
                deveFicarAmarela ||
                isSessaoEmAndamento ||
                (sessaoVisualAtualFoiFinalizada && item.globalIndex == min(iPosicaoAtual + 1, sectionItems.count)) ||
                (ehPrimeiraSessaoDoProximoModulo && totalPaginasSessaoAtual > 0 && totalTela >= totalPaginasSessaoAtual) ||
                (statusAtual == .proximaSessaoDisponivelNaoIniciada && sessaoAtual == sessao) ||
                (statusAtual != .bloqueado && sessaoAtual == sessao) ||
                sessaoAnteriorConcluida ||
                (moduloAtual > modIdx) ||
                (moduloAtual == modIdx && sessaoAtual > sessao)

            let isBlocked = !sessaoJaPercorridaSemBloqueio && statusAtual == .proximaLiberado && !jaFoiConcluidaVisualmente

            // Determine image state (imagem1/2/3)
            let imageState: TrailItemState.ImageState
            let isSpecial = (9...11).contains(modIdx)

            if isSpecial {
                imageState = .available
            } else if estaAntesDaSessaoAtualNoCaminho {
                imageState = .completed
            } else if ehPrimeiraSessaoDoModulo1 {
                if jaFoiConcluidaVisualmente || jaAvancouDepoisDaPrimeiraSessao {
                    imageState = .completed
                } else if deveFicarAmarela || isSessaoEmAndamento {
                    imageState = .inProgress
                } else if statusAtual == .sessaoConcluida {
                    imageState = .completed
                } else {
                    imageState = .available
                }
            } else if statusAtual == .liberado || jaFoiConcluidaVisualmente || deveFicarAmarela || isPosicaoVisualAtual || isSessaoEmAndamento {
                if sessaoAtualFoiFinalizadaVisualmente ||
                    (jaFoiConcluidaVisualmente && statusAtual == .sessaoConcluida) ||
                    (item.globalIndex < iOndeEstou && !existeEmAndamento) {
                    imageState = .completed
                } else if (deveFicarAmarela || isSessaoEmAndamento) && totalPaginasSessaoAtual > 0 {
                    imageState = .inProgress
                } else if isPosicaoVisualAtual {
                    imageState = .inProgress
                } else if isProximaSessaoLiberada || (item.globalIndex == iOndeEstou && totalTela >= totalPaginasSessaoAtual) {
                    imageState = .available
                } else {
                    imageState = .completed
                }
            } else {
                imageState = statusAtual == .bloqueado ? .locked : .available
            }

            // Divider: show at the first section of each module level group
            let levelGroup = levelGroup(for: modIdx)
            let showDiv = secIdx == 0 && levelGroup != previousModuleGroup
            if showDiv { previousModuleGroup = levelGroup }

            return TrailItemState(
                sectionItem: item,
                imageState: imageState,
                isClickable: isClickableSeTerminou,
                isBlocked: isBlocked,
                showHereIndicator: isPosicaoVisualAtual,
                showDivider: showDiv,
                dividerLabel: dividerLabel(for: modIdx),
                isSpecialModule: isSpecial
            )
        }
    }

    private func levelGroup(for modIdx: Int) -> Int {
        switch modIdx {
        case ...2: return 0
        case 3...4: return 1
        case 5...6: return 2
        case 7...8: return 3
        default: return 4
        }
    }

    private func dividerLabel(for modIdx: Int) -> String {
        switch modIdx {
        case ...2: return "NÍVEL INICIANTE"
        case 3...4: return "NÍVEL INTERMEDIÁRIO"
        case 5...6: return "NÍVEL AVANÇADO"
        case 7...8: return "NÍVEL ESPECIALISTA"
        default: return ""
        }
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
