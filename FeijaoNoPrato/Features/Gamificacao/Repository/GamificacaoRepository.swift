// GamificacaoRepository.swift
// Replaces pontos/repository/GamificacaoRepository.kt

import Foundation

struct PutRespostaBody: Encodable {
    let valor: String
    let complemento: String
}

final class GamificacaoRepository {

    private let appPreferences: AppPreferences
    private let authPreferences: AuthPreferences
    private let networkClient: NetworkClient

    private let chave = "pontos_usuario"

    // In-memory pontuação kept up to date after each sync/save so dedup works without extra network calls.
    private var livePontuacao: PontuacaoUsuario = PontuacaoUsuario()
    // Raw JSON dict received from backend, used as base for saves to preserve unknown fields.
    private var rawBackendDict: [String: Any]? = nil

    init(appPreferences: AppPreferences, authPreferences: AuthPreferences, networkClient: NetworkClient) {
        self.appPreferences = appPreferences
        self.authPreferences = authPreferences
        self.networkClient = networkClient
    }

    // MARK: - Remote sync

    func sincronizar() async -> PontuacaoUsuario {
        guard let token = authPreferences.token else {
            return cachedPontuacao()
        }
        do {
            let response: ProgressResponse = try await networkClient.getWithAuth(
                "api/zRespondente/resposta/\(chave)",
                bearer: token,
                type: ProgressResponse.self
            )
            // Android stores numbers as strings and may double-encode Valor as a JSON string.
            // Use the same tolerant parsing to handle both formats.
            if let (pontuacao, rawDict) = parsePontuacao(response.Valor) {
                rawBackendDict = rawDict
                livePontuacao = pontuacao
                appPreferences.gamificacaoPoints = pontuacao.totalAcumulado
                appPreferences.gamificacaoPontosConsumidos = pontuacao.totalConsumido
                appPreferences.rescuedItems = pontuacao.list_rescue
                if pontuacao.ultimoModulo > 0 { appPreferences.ultimoModulo = pontuacao.ultimoModulo }
                if pontuacao.ultimoSessao > 0 { appPreferences.ultimoSessao = pontuacao.ultimoSessao }
                return pontuacao
            }
        } catch {
            // fall through to cached
        }
        return cachedPontuacao()
    }

    // MARK: - Add points (mirrors Android GamificacaoRepository.adicionarPontos)

    func adicionarPontos(modulo_numero: String, modulo: String, atividade: String, pontos: Int, referenciaUnica: String) async {
        guard let token = authPreferences.token, pontos > 0 else { return }

        let atividadeKey = "\(modulo_numero)|\(modulo)|\(atividade)|\(referenciaUnica)"

        if deveEvitarDuplicidade(atividade) {
            let ignoraReferencia = ehAtividadeUnicaPorModulo(atividade)
            let jaPontuou = livePontuacao.atividadesPontuadasUnicas.contains(atividadeKey) ||
                livePontuacao.historico.contains(where: { item in
                    item.modulo_numero == modulo_numero &&
                    item.modulo == modulo &&
                    item.atividade == atividade &&
                    (ignoraReferencia || item.referenciaUnica == referenciaUnica)
                })

            if jaPontuou {
                if !livePontuacao.atividadesPontuadasUnicas.contains(atividadeKey) {
                    livePontuacao.atividadesPontuadasUnicas.append(atividadeKey)
                    await salvar(token: token)
                }
                return
            }
            livePontuacao.atividadesPontuadasUnicas.append(atividadeKey)
        }

        let formatter = ISO8601DateFormatter()
        let registro = PontoAtividade(
            modulo_numero: modulo_numero,
            modulo: modulo,
            atividade: atividade,
            pontos: pontos,
            data: formatter.string(from: Date()),
            referenciaUnica: referenciaUnica
        )
        livePontuacao.historico.append(registro)
        livePontuacao.totalAcumulado += pontos
        appPreferences.gamificacaoPoints = livePontuacao.totalAcumulado

        await salvar(token: token)
    }

    // Saves livePontuacao to backend, merging with rawBackendDict to preserve fields iOS doesn't track.
    private func salvar(token: String) async {
        let jsonValor = buildBackendJson()
        let body = PutRespostaBody(valor: jsonValor, complemento: "")
        do {
            try await networkClient.putWithAuth(
                "api/zRespondente/resposta/\(chave)",
                bearer: token,
                body: body
            )
        } catch {
            // silent: local livePontuacao still updated; next sync will reconcile
        }
    }

    private func buildBackendJson() -> String {
        // Start from raw backend dict to preserve unknown fields (dataNacimento, nomeUsuario, etc.)
        var dict: [String: Any] = rawBackendDict ?? [:]

        dict["totalAcumulado"] = String(livePontuacao.totalAcumulado)
        dict["totalConsumido"] = String(livePontuacao.totalConsumido)
        dict["ultimoModulo"] = String(livePontuacao.ultimoModulo)
        dict["ultimoSessao"] = String(livePontuacao.ultimoSessao)
        dict["list_rescue"] = livePontuacao.list_rescue

        dict["historico"] = livePontuacao.historico.map { item in
            [
                "modulo_numero": item.modulo_numero,
                "modulo": item.modulo,
                "atividade": item.atividade,
                "pontos": String(item.pontos),
                "data": item.data,
                "referenciaUnica": item.referenciaUnica
            ] as [String: Any]
        }

        dict["atividadesPontuadasUnicas"] = livePontuacao.atividadesPontuadasUnicas

        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let str = String(data: data, encoding: .utf8) else { return "{}" }
        return str
    }

    // MARK: - Duplicate prevention (mirrors DuplicidadeDePontuacao.kt)

    private func deveEvitarDuplicidade(_ atividade: String) -> Bool {
        atividade == "[FIXANDO]" ||
        atividade.hasPrefix("[CHECK_CONCLUIDO") ||
        ehAtividadeUnicaPorModulo(atividade)
    }

    private func ehAtividadeUnicaPorModulo(_ atividade: String) -> Bool {
        atividade == "[FOTOS]"
    }

    // Mirrors Android GamificacaoRepository.parsePontuacao — handles:
    // 1. Valor as a JSON object string: {"totalAcumulado":"925",...}
    // 2. Valor as a double-encoded string: "{\"totalAcumulado\":\"925\",...}"
    // 3. Numbers stored as JSON strings by the Android backend
    // Returns the parsed model AND the raw dict (to preserve unknown fields on save).
    private func parsePontuacao(_ rawJson: String) -> (PontuacaoUsuario, [String: Any])? {
        // Unwrap double-encoded string if needed (mirrors Android unwrapJsonString)
        let jsonString: String
        if let data = rawJson.data(using: .utf8),
           let outer = try? JSONSerialization.jsonObject(with: data),
           let inner = outer as? String {
            jsonString = inner
        } else {
            jsonString = rawJson
        }

        guard let data = jsonString.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        func readInt(_ key: String, default def: Int = 0) -> Int {
            guard let val = obj[key] else { return def }
            if let n = val as? Int { return n }
            if let s = val as? String { return Int(s) ?? def }
            if let d = val as? Double { return Int(d) }
            return def
        }

        func readIntArray(_ key: String) -> [Int] {
            guard let arr = obj[key] as? [Any] else { return [] }
            return arr.compactMap { item -> Int? in
                if let n = item as? Int { return n }
                if let s = item as? String { return Int(s) }
                if let d = item as? Double { return Int(d) }
                return nil
            }
        }

        let totalAcumulado = readInt("totalAcumulado")
        let totalConsumido = readInt("totalConsumido")
        let ultimoModulo   = readInt("ultimoModulo", default: 1)
        let ultimoSessao   = readInt("ultimoSessao", default: 1)
        let listRescue     = readIntArray("list_rescue")

        var historico: [PontoAtividade] = []
        if let arr = obj["historico"] as? [[String: Any]] {
            historico = arr.compactMap { item in
                guard let modulo_numero = item["modulo_numero"] as? String,
                      let modulo = item["modulo"] as? String,
                      let atividade = item["atividade"] as? String,
                      let data = item["data"] as? String else { return nil }
                let pontos: Int = {
                    if let n = item["pontos"] as? Int { return n }
                    if let s = item["pontos"] as? String { return Int(s) ?? 0 }
                    return 0
                }()
                let ref = item["referenciaUnica"] as? String ?? ""
                return PontoAtividade(
                    modulo_numero: modulo_numero, modulo: modulo,
                    atividade: atividade, pontos: pontos, data: data, referenciaUnica: ref
                )
            }
        }

        let atividadesUnicas: [String] = (obj["atividadesPontuadasUnicas"] as? [String]) ?? []

        let pontuacao = PontuacaoUsuario(
            totalAcumulado: totalAcumulado,
            totalConsumido: totalConsumido,
            ultimoModulo: ultimoModulo,
            ultimoSessao: ultimoSessao,
            list_rescue: listRescue,
            historico: historico,
            atividadesPontuadasUnicas: atividadesUnicas
        )
        return (pontuacao, obj)
    }

    // MARK: - Local access

    func cachedPontuacao() -> PontuacaoUsuario {
        PontuacaoUsuario(
            totalAcumulado: appPreferences.gamificacaoPoints,
            totalConsumido: appPreferences.gamificacaoPontosConsumidos,
            ultimoModulo: appPreferences.ultimoModulo,
            ultimoSessao: appPreferences.ultimoSessao,
            list_rescue: appPreferences.rescuedItems
        )
    }

    func addPoints(_ amount: Int) {
        appPreferences.gamificacaoPoints += amount
    }

    func consumePoints(_ amount: Int) {
        appPreferences.gamificacaoPontosConsumidos = max(0, appPreferences.gamificacaoPontosConsumidos - amount)
    }

    func getRescuedItems() -> [Int] {
        appPreferences.rescuedItems
    }

    func addRescuedItem(id: Int) {
        var list = appPreferences.rescuedItems
        if !list.contains(id) {
            list.append(id)
            appPreferences.rescuedItems = list
        }
    }

    func clearLocalData() {
        appPreferences.gamificacaoPoints = 0
        appPreferences.gamificacaoPontosConsumidos = 0
        appPreferences.rescuedItems = []
        livePontuacao = PontuacaoUsuario()
        rawBackendDict = nil
    }
}
