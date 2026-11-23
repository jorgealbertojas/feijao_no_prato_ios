// AppPreferences.swift
// Replaces data/local/AppPreferences.kt

import Foundation

final class AppPreferences {

    private let defaults = UserDefaults.standard

    private enum Key: String, CaseIterable {
        case userName = "app_user_name"
        case userEmail = "app_user_email"
        case birthDate = "app_birth_date"
        case hasCompletedIntro = "app_has_completed_intro"
        case gamificacaoPoints = "app_gamificacao_points"
        case gamificacaoPontosConsumidos = "app_gamificacao_pontos_consumidos"
        case ultimoModulo = "app_ultimo_modulo"
        case ultimoSessao = "app_ultimo_sessao"
        case iaQuantity = "app_ia_quantity"
        // Progress tracking
        case moduloAtual = "app_modulo_atual"
        case sessaoAtual = "app_sessao_atual"
        case moduloVisual = "app_modulo_visual"
        case sessaoVisual = "app_sessao_visual"
        case moduloVisualMax = "app_modulo_visual_max"
        case sessaoVisualMax = "app_sessao_visual_max"
        case moduloConcluido = "app_modulo_concluido"
        case sessaoConcluida = "app_sessao_concluida"
        case nivelAtual = "app_nivel_atual"
        case titleSalvo = "app_title_salvo"
        case totalTela = "app_total_tela"
        case lastSection = "app_last_section"
        case paragraphIndex = "app_paragraph_index"
        case totalCamera = "app_total_camera"
        case alimentacaoScores = "app_alimentacao_scores"
        case rescuedItems = "app_rescued_items"
    }

    var userName: String? {
        get { defaults.string(forKey: Key.userName.rawValue) }
        set { defaults.set(newValue, forKey: Key.userName.rawValue) }
    }

    var userEmail: String? {
        get { defaults.string(forKey: Key.userEmail.rawValue) }
        set { defaults.set(newValue, forKey: Key.userEmail.rawValue) }
    }

    var birthDate: String? {
        get { defaults.string(forKey: Key.birthDate.rawValue) }
        set { defaults.set(newValue, forKey: Key.birthDate.rawValue) }
    }

    var hasCompletedIntro: Bool {
        get { defaults.bool(forKey: Key.hasCompletedIntro.rawValue) }
        set { defaults.set(newValue, forKey: Key.hasCompletedIntro.rawValue) }
    }

    var gamificacaoPoints: Int {
        get { defaults.integer(forKey: Key.gamificacaoPoints.rawValue) }
        set { defaults.set(newValue, forKey: Key.gamificacaoPoints.rawValue) }
    }

    var gamificacaoPontosConsumidos: Int {
        get { defaults.integer(forKey: Key.gamificacaoPontosConsumidos.rawValue) }
        set { defaults.set(newValue, forKey: Key.gamificacaoPontosConsumidos.rawValue) }
    }

    var ultimoModulo: Int {
        get { defaults.integer(forKey: Key.ultimoModulo.rawValue) }
        set { defaults.set(newValue, forKey: Key.ultimoModulo.rawValue) }
    }

    var ultimoSessao: Int {
        get { defaults.integer(forKey: Key.ultimoSessao.rawValue) }
        set { defaults.set(newValue, forKey: Key.ultimoSessao.rawValue) }
    }

    var iaQuantity: Int {
        get { defaults.integer(forKey: Key.iaQuantity.rawValue) }
        set { defaults.set(newValue, forKey: Key.iaQuantity.rawValue) }
    }

    // MARK: - Progress tracking

    var moduloAtual: Int {
        get { defaults.integer(forKey: Key.moduloAtual.rawValue) }
        set { defaults.set(newValue, forKey: Key.moduloAtual.rawValue) }
    }

    var sessaoAtual: Int {
        get { defaults.integer(forKey: Key.sessaoAtual.rawValue) }
        set { defaults.set(newValue, forKey: Key.sessaoAtual.rawValue) }
    }

    var moduloVisual: Int {
        get { defaults.integer(forKey: Key.moduloVisual.rawValue) }
        set { defaults.set(newValue, forKey: Key.moduloVisual.rawValue) }
    }

    var sessaoVisual: Int {
        get { defaults.integer(forKey: Key.sessaoVisual.rawValue) }
        set { defaults.set(newValue, forKey: Key.sessaoVisual.rawValue) }
    }

    var moduloVisualMax: Int {
        get { defaults.integer(forKey: Key.moduloVisualMax.rawValue) }
        set { defaults.set(newValue, forKey: Key.moduloVisualMax.rawValue) }
    }

    var sessaoVisualMax: Int {
        get { defaults.integer(forKey: Key.sessaoVisualMax.rawValue) }
        set { defaults.set(newValue, forKey: Key.sessaoVisualMax.rawValue) }
    }

    var moduloConcluido: Int {
        get { defaults.integer(forKey: Key.moduloConcluido.rawValue) }
        set { defaults.set(newValue, forKey: Key.moduloConcluido.rawValue) }
    }

    var sessaoConcluida: Int {
        get { defaults.integer(forKey: Key.sessaoConcluida.rawValue) }
        set { defaults.set(newValue, forKey: Key.sessaoConcluida.rawValue) }
    }

    var nivelAtual: String {
        get { defaults.string(forKey: Key.nivelAtual.rawValue) ?? "" }
        set { defaults.set(newValue, forKey: Key.nivelAtual.rawValue) }
    }

    var titleSalvo: String {
        get { defaults.string(forKey: Key.titleSalvo.rawValue) ?? "" }
        set { defaults.set(newValue, forKey: Key.titleSalvo.rawValue) }
    }

    var totalTela: Int {
        get { defaults.integer(forKey: Key.totalTela.rawValue) }
        set { defaults.set(newValue, forKey: Key.totalTela.rawValue) }
    }

    var lastSection: Int {
        get { defaults.integer(forKey: Key.lastSection.rawValue) }
        set { defaults.set(newValue, forKey: Key.lastSection.rawValue) }
    }

    var paragraphIndex: Int {
        get { defaults.integer(forKey: Key.paragraphIndex.rawValue) }
        set { defaults.set(newValue, forKey: Key.paragraphIndex.rawValue) }
    }

    // MARK: - Session-specific page tracking (keyed by module+session)

    func getSessionTotalPages(modulo: Int, sessao: Int) -> Int {
        defaults.integer(forKey: "app_session_total_pages_\(modulo)_\(sessao)")
    }

    func saveSessionTotalPages(modulo: Int, sessao: Int, total: Int) {
        defaults.set(total, forKey: "app_session_total_pages_\(modulo)_\(sessao)")
    }

    func getSessionViewedPages(modulo: Int, sessao: Int) -> Int {
        defaults.integer(forKey: "app_session_viewed_pages_\(modulo)_\(sessao)")
    }

    func saveSessionViewedPages(modulo: Int, sessao: Int, viewed: Int) {
        defaults.set(viewed, forKey: "app_session_viewed_pages_\(modulo)_\(sessao)")
    }

    func getSessionPageIndex(modulo: Int, sessao: Int) -> Int {
        defaults.integer(forKey: "app_session_page_index_\(modulo)_\(sessao)")
    }

    func saveSessionPageIndex(modulo: Int, sessao: Int, index: Int) {
        defaults.set(index, forKey: "app_session_page_index_\(modulo)_\(sessao)")
    }

    func clearSessionPageIndex(modulo: Int, sessao: Int) {
        defaults.removeObject(forKey: "app_session_page_index_\(modulo)_\(sessao)")
    }

    var totalCamera: Int {
        get { defaults.integer(forKey: Key.totalCamera.rawValue) }
        set { defaults.set(newValue, forKey: Key.totalCamera.rawValue) }
    }

    var alimentacaoScores: [Int] {
        get { defaults.array(forKey: Key.alimentacaoScores.rawValue) as? [Int] ?? [] }
        set { defaults.set(newValue, forKey: Key.alimentacaoScores.rawValue) }
    }

    var rescuedItems: [Int] {
        get { defaults.array(forKey: Key.rescuedItems.rawValue) as? [Int] ?? [] }
        set { defaults.set(newValue, forKey: Key.rescuedItems.rawValue) }
    }

    func saveUserProgress(currentModule: Int, currentSection: Int) {
        moduloAtual = currentModule
        sessaoAtual = currentSection
    }

    func clearAll() {
        Key.allCases.forEach { defaults.removeObject(forKey: $0.rawValue) }
    }
}
