// ScreenSectionViewModel.swift
// Ports ScreenSection.kt + SessionViewModel.kt logic

import Foundation

enum SectionLoadState {
    case idle, loading, loaded, error(String)
}

@MainActor
final class ScreenSectionViewModel: ObservableObject {

    // MARK: - Published state

    @Published var loadState: SectionLoadState = .idle
    @Published var pages: [SectionPage] = []
    @Published var currentPageIndex: Int = 0
    @Published var imageBaseURL: String = ""

    // Quiz state for current page
    @Published var selectedOption: String? = nil
    @Published var showFeedback: Bool = false
    @Published var feedbackIsCorrect: Bool = false
    @Published var feedbackText: String = ""

    // Running count of correct answers in this session (mirrors tempCorrectCount in Android)
    @Published var tempCorrectCount: Int = 0

    // Session concluded flag (shown on completion)
    @Published var sessionConcluded: Bool = false

    // MARK: - Private

    private let repository = ScreenSectionRepository()
    private let prefs = AppPreferences()
    private let levelsSource = LocalLevelsDataSource()

    private(set) var moduloAtual: Int = 0
    private(set) var sessaoAtual: Int = 0  // 0-based internal

    // MARK: - Computed

    var totalPages: Int { pages.count }

    var progress: Float {
        guard totalPages > 0 else { return 0 }
        return Float(currentPageIndex + 1) / Float(totalPages)
    }

    var currentPage: SectionPage? {
        guard currentPageIndex < pages.count else { return nil }
        return pages[currentPageIndex]
    }

    var moduloLabel: String { "MÓDULO \(moduloAtual), SEÇÃO \(sessaoAtual + 1)" }

    var prevVisible: Bool { currentPage?.botaoAnterior?.visivel == true }

    var nextDescricao: String { currentPage?.botaoProximo?.descricao ?? "Próximo" }
    var nextVisible: Bool { currentPage?.botaoProximo?.visivel != false }

    var isLastPage: Bool { currentPageIndex == totalPages - 1 }

    // MARK: - Load

    func load() {
        moduloAtual = prefs.moduloVisual
        sessaoAtual = prefs.sessaoVisual - 1  // sessaoVisual is 1-based, API uses 1-based too

        // Restore saved page index if available
        let savedIndex = prefs.getSessionPageIndex(modulo: moduloAtual, sessao: sessaoAtual + 1)
        currentPageIndex = savedIndex

        Task {
            await fetchContent()
        }
    }

    private func fetchContent() async {
        loadState = .loading
        do {
            // API uses modulo (1-based) and secao (1-based)
            let response = try await repository.fetchSection(modulo: moduloAtual, secao: sessaoAtual + 1)
            let modulo = response.modulos?.first
            imageBaseURL = modulo?.urlRaizImagens ?? ""
            pages = modulo?.secoes?.first?.paginas ?? []
            prefs.saveSessionTotalPages(modulo: moduloAtual, sessao: sessaoAtual + 1, total: pages.count)
            loadState = .loaded
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }

    // MARK: - Navigation

    func goNext() {
        guard currentPageIndex < totalPages - 1 else {
            registrarConclusaoSessaoSeNecessario()
            return
        }
        currentPageIndex += 1
        selectedOption = nil
        showFeedback = false
        savePageProgress()
    }

    func goPrev() {
        guard currentPageIndex > 0 else { return }
        currentPageIndex -= 1
        selectedOption = nil
        showFeedback = false
        savePageProgress()
    }

    // Called when user taps "CONFIRMAR" on a quiz page
    func confirmarResposta() {
        guard let page = currentPage,
              let items = page.itens else { return }

        let pergunta = items.first(where: { $0.tipo == "Pergunta" })
        guard let pergunta else { return }

        guard let selected = selectedOption, !selected.isEmpty else { return }

        let opcoes = pergunta.opcoes ?? []

        // [SELECT_SLIDER_NUMBER] / [SELECT_SLIDER_NUMBER_QUEST]: always correct — slider records value, no wrong answer
        if pergunta.personalizacao == "[SELECT_SLIDER_NUMBER]"
            || pergunta.personalizacao == "[SELECT_SLIDER_NUMBER_QUEST]" {
            feedbackIsCorrect = true
            feedbackText = pergunta.textoFeedbackPositivo ?? "Ótimo! Continue assim."
            showFeedback = true
            return
        }

        // [SELECT_MULT]: single selection from ingredient list — same logic as normal quiz
        if pergunta.personalizacao == "[SELECT_MULT]" {
            let selectedOpcao = opcoes.first(where: { $0.descricao == selected })
            let isCorrect = selectedOpcao?.ehCorreta == "true"

            feedbackIsCorrect = isCorrect
            feedbackText = isCorrect
                ? (pergunta.textoFeedbackPositivo ?? "Correto!")
                : (selectedOpcao?.textoFeedbackNegativo
                   ?? opcoes.first(where: { $0.ehCorreta == "true" })?.textoFeedbackNegativo
                   ?? "Tente novamente.")
            showFeedback = true
            return
        }

        // Single-select
        let selectedOpcao = opcoes.first(where: { $0.descricao == selected })
        let correta = pergunta.descricaOopcaoCorreta
        let isCorrect = selected == correta || selectedOpcao?.ehCorreta == "true"

        feedbackIsCorrect = isCorrect
        feedbackText = isCorrect
            ? (pergunta.textoFeedbackPositivo ?? "Correto!")
            : (selectedOpcao?.textoFeedbackNegativo ?? "Tente novamente.")
        showFeedback = true
    }

    func dismissFeedbackAndAdvance() {
        if feedbackIsCorrect { tempCorrectCount += 1 }
        showFeedback = false
        goNext()
    }

    // MARK: - Completion

    func registrarConclusaoSessaoSeNecessario() {
        let modulo = moduloAtual
        let sessao = sessaoAtual + 1  // 1-based

        // Only advance if this is a new record
        let currentConcluido = prefs.moduloConcluido
        let currentSessaoConcluida = prefs.sessaoConcluida

        let eNovo = modulo > currentConcluido ||
            (modulo == currentConcluido && sessao > currentSessaoConcluida)

        if eNovo {
            prefs.moduloConcluido = modulo
            prefs.sessaoConcluida = sessao
        }

        // Advance visual pointer to next section
        let totalSessoes = totalDeSecoesDoModulo(modulo: modulo)
        if sessao < totalSessoes {
            prefs.moduloVisual = modulo
            prefs.sessaoVisual = sessao + 1
        } else {
            prefs.moduloVisual = modulo + 1
            prefs.sessaoVisual = 1
        }

        // Also update max visual reached
        let newModVisual = prefs.moduloVisual
        let newSesVisual = prefs.sessaoVisual
        let currentMax = prefs.moduloVisualMax
        let currentMaxSes = prefs.sessaoVisualMax
        if newModVisual > currentMax || (newModVisual == currentMax && newSesVisual > currentMaxSes) {
            prefs.moduloVisualMax = newModVisual
            prefs.sessaoVisualMax = newSesVisual
        }

        prefs.clearSessionPageIndex(modulo: modulo, sessao: sessao)
        sessionConcluded = true
    }

    // MARK: - Private helpers

    private func savePageProgress() {
        let sessao = sessaoAtual + 1
        prefs.saveSessionPageIndex(modulo: moduloAtual, sessao: sessao, index: currentPageIndex)
        prefs.saveSessionViewedPages(modulo: moduloAtual, sessao: sessao, viewed: currentPageIndex + 1)
    }

    private func totalDeSecoesDoModulo(modulo: Int) -> Int {
        let levels = levelsSource.loadLevels()
        let all = levels.flatMap { $0.module }
        guard modulo > 0, modulo <= all.count else { return 0 }
        return all[modulo - 1].section.count
    }
}
