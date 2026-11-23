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
    let tamanho: String?
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
}

struct SectionItemImage: Codable {
    let nomeArquivo: String?
    let modelo: String?

    enum CodingKeys: String, CodingKey {
        case nomeArquivo = "NomeArquivo"
        case modelo = "Modelo"
    }
}
