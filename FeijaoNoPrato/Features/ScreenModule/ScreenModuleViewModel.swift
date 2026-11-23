// ScreenModuleViewModel.swift
// Replaces ScreenModule.kt logic + ProgressoDoModulo.kt

import Foundation

@MainActor
final class ScreenModuleViewModel: ObservableObject {

    @Published var modules: [ModuleData] = []
    @Published var selectedTabIndex: Int = 0

    // Progress values read from prefs
    @Published var moduloConcluido: Int = 0
    @Published var sessaoConcluida: Int = 0
    @Published var moduloVisual: Int = 0
    @Published var sessaoVisual: Int = 0
    @Published var moduloVisualMax: Int = 0
    @Published var sessaoVisualMax: Int = 0
    @Published var totalTela: Int = 0

    private let prefs = AppPreferences()
    private let dataSource = LocalLevelsDataSource()

    func load() {
        let levels = dataSource.loadLevels()
        // Flatten all modules across levels, drop last 3 special modules (same as Android)
        let all = levels.flatMap { $0.module }
        modules = all.count > 3 ? Array(all.dropLast(3)) : all

        loadPrefs()

        // Open the tab for the current module in progress (1-based → 0-based)
        let initial = max(0, prefs.moduloVisualMax - 1)
        selectedTabIndex = min(initial, max(0, modules.count - 1))
    }

    func refreshPrefs() {
        loadPrefs()
    }

    // MARK: - Progress

    func progressForModule(at tabIndex: Int) -> Float {
        guard tabIndex < modules.count else { return 0 }
        let module = modules[tabIndex]
        let modulo = tabIndex + 1   // 1-based module number
        let totalDeSecoes = module.section.count
        return progressoDoModulo(
            modulo: modulo,
            totalDeSecoes: totalDeSecoes,
            moduloConcluido: moduloConcluido,
            sessaoConcluida: sessaoConcluida
        )
    }

    // MARK: - Session card state

    func sessionState(section: SectionData, sectionIndex: Int, tabIndex: Int) -> SessionCardState {
        let moduleIndex = tabIndex + 1   // 1-based
        let sessaoNumero = sectionIndex + 1

        let jaFoiConcluidaVisualmente =
            moduloConcluido > moduleIndex ||
            (moduloConcluido == moduleIndex && sessaoConcluida >= sessaoNumero)

        let sessaoAtualTemProgresso =
            moduloVisual == moduleIndex &&
            sessaoVisual == sessaoNumero &&
            totalTela > 0

        let isSessaoEmAndamento = sessaoAtualTemProgresso && !jaFoiConcluidaVisualmente

        let jaFoiAlcancadaVisualmente =
            moduloVisualMax > moduleIndex ||
            (moduloVisualMax == moduleIndex && sessaoVisualMax >= sessaoNumero)

        let deveFicarAmarela =
            jaFoiAlcancadaVisualmente &&
            !jaFoiConcluidaVisualmente &&
            sessaoAtualTemProgresso

        let habilitado =
            jaFoiConcluidaVisualmente ||
            deveFicarAmarela ||
            isSessaoEmAndamento ||
            (moduleIndex == 1 && sectionIndex == 0)

        let status: SessionCardStatus
        if jaFoiConcluidaVisualmente {
            status = .completed
        } else if deveFicarAmarela || isSessaoEmAndamento {
            status = .inProgress
        } else {
            status = .locked
        }

        return SessionCardState(
            section: section,
            moduleIndex: moduleIndex,
            sectionIndex: sectionIndex,
            status: status,
            isEnabled: habilitado
        )
    }

    // MARK: - Private

    private func loadPrefs() {
        moduloConcluido = prefs.moduloConcluido
        sessaoConcluida = prefs.sessaoConcluida
        moduloVisual = prefs.moduloVisual
        sessaoVisual = prefs.sessaoVisual
        moduloVisualMax = prefs.moduloVisualMax
        sessaoVisualMax = prefs.sessaoVisualMax
        totalTela = prefs.totalTela
    }
}

// MARK: - ProgressoDoModulo (port of ProgressoDoModulo.kt)

func secoesConcluidasNoModulo(modulo: Int, totalDeSecoes: Int, moduloConcluido: Int, sessaoConcluida: Int) -> Int {
    guard totalDeSecoes > 0 else { return 0 }
    if moduloConcluido > modulo { return totalDeSecoes }
    if moduloConcluido == modulo { return min(sessaoConcluida, totalDeSecoes) }
    return 0
}

func progressoDoModulo(modulo: Int, totalDeSecoes: Int, moduloConcluido: Int, sessaoConcluida: Int) -> Float {
    guard totalDeSecoes > 0 else { return 0 }
    let concluidas = secoesConcluidasNoModulo(
        modulo: modulo,
        totalDeSecoes: totalDeSecoes,
        moduloConcluido: moduloConcluido,
        sessaoConcluida: sessaoConcluida
    )
    return Float(concluidas) / Float(totalDeSecoes)
}

// MARK: - Session card state model

enum SessionCardStatus {
    case completed
    case inProgress
    case locked
}

struct SessionCardState: Identifiable {
    let section: SectionData
    let moduleIndex: Int   // 1-based
    let sectionIndex: Int  // 0-based
    let status: SessionCardStatus
    let isEnabled: Bool

    var id: String { "\(moduleIndex)_\(sectionIndex)" }
    var sessaoNumero: Int { sectionIndex + 1 }

    var statusText: String {
        switch status {
        case .completed: return "CONCLUÍDO"
        case .inProgress: return "EM ANDAMENTO"
        case .locked: return "BLOQUEADO"
        }
    }
}
