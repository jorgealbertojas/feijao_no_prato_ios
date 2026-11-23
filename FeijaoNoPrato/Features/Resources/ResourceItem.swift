// ResourceItem.swift
// Replaces ui/screens/resources/data/ResourceItem.kt

import Foundation
import SwiftUI

struct ResourceItem: Codable, Hashable {
    let id: Int
    let categoria: String
    let name: String
    let pontos: Int
    let tipo: String
    let descricao: String
    let imageUrl: String
    let type: String
    let subcategoria: String
    let titulos: String
    let link: String
    let imagens: String
    let tipos: String
    let descricao__110: String
    let quantidade: Int
    let compartilhar: String?
    let listArrayResourceItem: [ResourceItem]

    // Tolerant decoding: missing String fields default to ""
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id               = try c.decode(Int.self, forKey: .id)
        categoria        = try c.decodeIfPresent(String.self, forKey: .categoria)        ?? ""
        name             = try c.decodeIfPresent(String.self, forKey: .name)             ?? ""
        pontos           = try c.decodeIfPresent(Int.self,    forKey: .pontos)           ?? 0
        tipo             = try c.decodeIfPresent(String.self, forKey: .tipo)             ?? ""
        descricao        = try c.decodeIfPresent(String.self, forKey: .descricao)        ?? ""
        imageUrl         = try c.decodeIfPresent(String.self, forKey: .imageUrl)         ?? ""
        type             = try c.decodeIfPresent(String.self, forKey: .type)             ?? ""
        subcategoria     = try c.decodeIfPresent(String.self, forKey: .subcategoria)     ?? ""
        titulos          = try c.decodeIfPresent(String.self, forKey: .titulos)          ?? ""
        link             = try c.decodeIfPresent(String.self, forKey: .link)             ?? ""
        imagens          = try c.decodeIfPresent(String.self, forKey: .imagens)          ?? ""
        tipos            = try c.decodeIfPresent(String.self, forKey: .tipos)            ?? ""
        descricao__110   = try c.decodeIfPresent(String.self, forKey: .descricao__110)   ?? ""
        quantidade       = try c.decodeIfPresent(Int.self,    forKey: .quantidade)       ?? 0
        compartilhar     = try c.decodeIfPresent(String.self, forKey: .compartilhar)
        listArrayResourceItem = try c.decodeIfPresent([ResourceItem].self, forKey: .listArrayResourceItem) ?? []
    }

    // MARK: Convenience

    var displayTitle: String { titulos.isEmpty ? name : titulos }
    var displayDescription: String { descricao__110.isEmpty ? descricao : descricao__110 }

    func isAvailable(rescuedItems: [Int]) -> Bool {
        id == 0 || rescuedItems.contains(id)
    }

    // Category-consistent placeholder color derived from the imagens name
    var placeholderColor: Color {
        let hash = abs(imagens.isEmpty ? categoria.hashValue : imagens.hashValue)
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.42, brightness: 0.72)
    }
}
