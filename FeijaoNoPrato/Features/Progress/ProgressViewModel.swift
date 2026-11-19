// ProgressViewModel.swift
// Replaces viewmodel/ProgressViewModel.kt + ProgressoDoModulo.kt

import Foundation
import SwiftUI

// MARK: - ProgressViewModel

@MainActor
final class ProgressViewModel: ObservableObject {

    // MARK: - Published

    @Published var moduloConcluido: Int = 0
    @Published var sessaoConcluida: Int = 0
    @Published var moduloVisualMax: Int = 0
    @Published var sessaoVisualMax: Int = 0
    @Published var totalCamera: Int = 0
    @Published var alimentacaoScores: [Int] = []

    // MARK: - Private

    private let prefs = AppPreferences()

    // MARK: - Constants

    private let totalModulos = 8
    private let sessoesPorModulo = 7

    private let desafios: [(moduleNumber: Int, targetSession: Int)] = [
        (1, 7), (2, 7), (3, 7), (4, 7),
        (5, 7), (6, 1), (7, 1), (8, 1)
    ]

    // MARK: - Computed

    var sessoesCompletas: Int {
        guard moduloConcluido > 0 && sessaoConcluida > 0 else { return 0 }
        return max(0, (moduloConcluido - 1)) * sessoesPorModulo + max(0, sessaoConcluida)
    }

    var desafiosCompletos: Int {
        desafios.filter { d in
            moduloConcluido > d.moduleNumber ||
                (moduloConcluido == d.moduleNumber && sessaoConcluida >= d.targetSession)
        }.count
    }

    var modulosCompletos: Int { min(desafiosCompletos, totalModulos) }

    var progressoPercent: Int { Int((Float(modulosCompletos) / Float(totalModulos)) * 100) }

    var progressoFracao: Float { Float(modulosCompletos) / Float(totalModulos) }

    // MARK: - Load

    func carregar() {
        moduloConcluido = prefs.moduloConcluido
        sessaoConcluida = prefs.sessaoConcluida
        moduloVisualMax = prefs.moduloVisualMax
        sessaoVisualMax = prefs.sessaoVisualMax
        totalCamera = prefs.totalCamera
        alimentacaoScores = prefs.alimentacaoScores
    }

    // MARK: - Desafio status

    enum DesafioStatus { case concluido, emAndamento, naoIniciado }

    func statusDoDesafio(moduleNumber: Int) -> DesafioStatus {
        guard let d = desafios.first(where: { $0.moduleNumber == moduleNumber }) else {
            return .naoIniciado
        }
        let concluido = moduloConcluido > d.moduleNumber ||
            (moduloConcluido == d.moduleNumber && sessaoConcluida >= d.targetSession)
        let alcancado = moduloVisualMax > d.moduleNumber ||
            (moduloVisualMax == d.moduleNumber && sessaoVisualMax >= d.targetSession)
        if concluido { return .concluido }
        if alcancado { return .emAndamento }
        return .naoIniciado
    }

    func desafioAlcancado(moduleNumber: Int) -> Bool {
        guard let d = desafios.first(where: { $0.moduleNumber == moduleNumber }) else { return false }
        return moduloVisualMax > d.moduleNumber ||
            (moduloVisualMax == d.moduleNumber && sessaoVisualMax >= d.targetSession) ||
            moduloConcluido > d.moduleNumber ||
            (moduloConcluido == d.moduleNumber && sessaoConcluida >= d.targetSession)
    }
}
