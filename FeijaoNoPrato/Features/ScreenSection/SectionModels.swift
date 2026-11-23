// SectionModels.swift
// Codable models for zQuestionario API — mirrors ModelApi.kt
// API returns PascalCase keys; CodingKeys map them to camelCase Swift properties.

import Foundation

struct SectionResponse: Codable {
    let modulos: [SectionModule]?

    enum CodingKeys: String, CodingKey {
        case modulos = "Modulos"
    }
}

struct SectionModule: Codable {
    let urlRaizImagens: String?
    let secoes: [SectionGroup]?

    enum CodingKeys: String, CodingKey {
        case urlRaizImagens = "URLRaizImagens"
        case secoes = "Secoes"
    }
}

struct SectionGroup: Codable {
    let paginas: [SectionPage]?

    enum CodingKeys: String, CodingKey {
        case paginas = "Paginas"
    }
}

struct SectionPage: Codable {
    let itens: [SectionItem]?
    let exibirBarraSuperiorNavegacao: Bool?
    let botaoAnterior: SectionButton?
    let botaoProximo: SectionButton?

    enum CodingKeys: String, CodingKey {
        case itens = "Itens"
        case exibirBarraSuperiorNavegacao = "ExibirBarraSuperiorNavegacao"
        case botaoAnterior = "BotaoAnterior"
        case botaoProximo = "BotaoProximo"
    }
}

struct SectionButton: Codable {
    let descricao: String?
    let visivel: Bool?

    enum CodingKeys: String, CodingKey {
        case descricao = "Descricao"
        case visivel = "Visivel"
    }
}

struct SectionItem: Codable {
    let tipo: String?
    let texto: String?
    let id: String?
    let url: String?
    let personalizacao: String?
    let nomeArquivo: String?
    let alinhamento: String?
    let descricao: String?
    let tamanho: Double?
    let direcao: String?
    let modelo: String?
    let ehMultiplaEscolha: Bool?
    let descricaOopcaoCorreta: String?
    let textoFeedbackPositivo: String?
    let opcoes: [SectionOption]?
    let imagens: [SectionItemImage]?
    let itens: [SectionItem]?

    enum CodingKeys: String, CodingKey {
        case tipo = "Tipo"
        case texto = "Texto"
        case id = "Id"
        case url = "Url"
        case personalizacao = "Personalizacao"
        case nomeArquivo = "NomeArquivo"
        case alinhamento = "Alinhamento"
        case descricao = "Descricao"
        case tamanho = "Tamanho"
        case direcao = "Direcao"
        case modelo = "Modelo"
        case ehMultiplaEscolha = "EhMultiplaEscolha"
        case descricaOopcaoCorreta = "DescricaoOpcaoCorreta"
        case textoFeedbackPositivo = "TextoFeedbackPositivo"
        case opcoes = "Opcoes"
        case imagens = "Imagens"
        case itens = "Itens"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        tipo = try c.decodeIfPresent(String.self, forKey: .tipo)
        texto = try c.decodeIfPresent(String.self, forKey: .texto)
        id = try c.decodeIfPresent(String.self, forKey: .id)
        url = try c.decodeIfPresent(String.self, forKey: .url)
        personalizacao = try c.decodeIfPresent(String.self, forKey: .personalizacao)
        nomeArquivo = try c.decodeIfPresent(String.self, forKey: .nomeArquivo)
        alinhamento = try c.decodeIfPresent(String.self, forKey: .alinhamento)
        descricao = try c.decodeIfPresent(String.self, forKey: .descricao)
        // Tamanho: API sends a number; Gson coerces to String on Android, so defensive decode both.
        if let dbl = try? c.decodeIfPresent(Double.self, forKey: .tamanho) {
            tamanho = dbl
        } else if let str = try? c.decodeIfPresent(String.self, forKey: .tamanho) {
            tamanho = Double(str)
        } else {
            tamanho = nil
        }
        direcao = try c.decodeIfPresent(String.self, forKey: .direcao)
        modelo = try c.decodeIfPresent(String.self, forKey: .modelo)
        ehMultiplaEscolha = try c.decodeIfPresent(Bool.self, forKey: .ehMultiplaEscolha)
        descricaOopcaoCorreta = try c.decodeIfPresent(String.self, forKey: .descricaOopcaoCorreta)
        textoFeedbackPositivo = try c.decodeIfPresent(String.self, forKey: .textoFeedbackPositivo)
        opcoes = try c.decodeIfPresent([SectionOption].self, forKey: .opcoes)
        imagens = try c.decodeIfPresent([SectionItemImage].self, forKey: .imagens)
        itens = try c.decodeIfPresent([SectionItem].self, forKey: .itens)
    }
}

struct SectionOption: Codable {
    let descricao: String?
    let textoFeedbackNegativo: String?
    let ehCorreta: String?

    enum CodingKeys: String, CodingKey {
        case descricao = "Descricao"
        case textoFeedbackNegativo = "TextoFeedbackNegativo"
        case ehCorreta = "EhCorreta"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        descricao = try c.decodeIfPresent(String.self, forKey: .descricao)
        textoFeedbackNegativo = try c.decodeIfPresent(String.self, forKey: .textoFeedbackNegativo)
        // API may send EhCorreta as a JSON boolean (true/false) even though Android declares String.
        // Gson coerces boolean→String silently; JSONDecoder does not, so we handle both.
        if let boolVal = try? c.decode(Bool.self, forKey: .ehCorreta) {
            ehCorreta = boolVal ? "true" : "false"
        } else {
            ehCorreta = try c.decodeIfPresent(String.self, forKey: .ehCorreta)
        }
    }
}

struct SectionItemImage: Codable {
    let nomeArquivo: String?
    let modelo: String?

    enum CodingKeys: String, CodingKey {
        case nomeArquivo = "NomeArquivo"
        case modelo = "Modelo"
    }
}
