// ResourcesViewModel.swift
// Replaces ui/screens/resources/viewMoel/ResourcesViewModel.kt

import Foundation

@MainActor
final class ResourcesViewModel: ObservableObject {

    @Published var resources: [ResourceItem] = []
    @Published var disponibilidadeFiltro: DisponibilidadeFiltro? = nil
    @Published var categoriasFiltro: Set<String> = []
    @Published var showInfoBanner: Bool = true

    init(initialCategoria: String? = nil) {
        loadResources()
        if let cat = initialCategoria, !cat.isEmpty {
            categoriasFiltro = [cat]
        }
    }

    private func loadResources() {
        guard let url = Bundle.main.url(forResource: "resources_local", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        resources = (try? JSONDecoder().decode([ResourceItem].self, from: data)) ?? []
    }

    func toggleDisponibilidadeFiltro(_ filtro: DisponibilidadeFiltro) {
        disponibilidadeFiltro = (disponibilidadeFiltro == filtro) ? nil : filtro
    }

    func filteredItems(_ items: [ResourceItem], rescuedItems: [Int]) -> [ResourceItem] {
        var result = items
        if let filtro = disponibilidadeFiltro {
            result = result.filter { item in
                switch filtro {
                case .disponivel: return item.isAvailable(rescuedItems: rescuedItems)
                case .resgatar: return !item.isAvailable(rescuedItems: rescuedItems)
                }
            }
        }
        if !categoriasFiltro.isEmpty {
            result = result.filter { categoriasFiltro.contains($0.categoria) }
        }
        return result
    }

    var distinctCategories: [String] {
        var seen = Set<String>()
        return resources.compactMap { item -> String? in
            guard !seen.contains(item.categoria) else { return nil }
            seen.insert(item.categoria)
            return item.categoria
        }
    }

    func itemsFor(categoria: String) -> [ResourceItem] {
        resources.filter { $0.categoria == categoria }
    }
}

enum DisponibilidadeFiltro {
    case disponivel
    case resgatar
}
