// PontuacaoUsuario.swift
// Replaces pontos/data/PontuacaoUsuario.kt

import Foundation

struct PontuacaoUsuario: Codable {
    var totalAcumulado: Int = 0
    var totalConsumido: Int = 0
    var ultimoModulo: Int = 1
    var ultimoSessao: Int = 1
    var list_rescue: [Int] = []
    var historico: [PontoAtividade] = []

    var saldo: Int { totalAcumulado - totalConsumido }
}

struct PontoAtividade: Codable, Identifiable {
    var id: String { referenciaUnica.isEmpty ? "\(modulo_numero)_\(atividade)_\(data)" : referenciaUnica }
    let modulo_numero: String
    let modulo: String
    let atividade: String
    let pontos: Int
    let data: String
    let referenciaUnica: String

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        modulo_numero   = (try? c.decodeIfPresent(String.self, forKey: .modulo_numero)) ?? ""
        modulo          = (try? c.decodeIfPresent(String.self, forKey: .modulo))         ?? ""
        atividade       = (try? c.decodeIfPresent(String.self, forKey: .atividade))      ?? ""
        pontos          = (try? c.decodeIfPresent(Int.self,    forKey: .pontos))         ?? 0
        data            = (try? c.decodeIfPresent(String.self, forKey: .data))           ?? ""
        referenciaUnica = (try? c.decodeIfPresent(String.self, forKey: .referenciaUnica)) ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case modulo_numero, modulo, atividade, pontos, data, referenciaUnica
    }
}

// Response from GET /api/zRespondente/resposta/{chave}
struct ProgressResponse: Codable {
    let IdRespondente: String
    let Chave: String
    let Valor: String
    let Complemento: String
}
