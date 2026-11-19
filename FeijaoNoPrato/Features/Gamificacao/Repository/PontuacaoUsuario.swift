// PontuacaoUsuario.swift
// Replaces pontos/data/PontuacaoUsuario.kt

import Foundation

struct PontuacaoUsuario: Codable {
    var totalAcumulado: Int
    var totalConsumido: Int

    var saldo: Int { totalAcumulado - totalConsumido }
}
