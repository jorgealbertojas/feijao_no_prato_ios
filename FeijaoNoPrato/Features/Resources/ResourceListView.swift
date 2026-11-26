// ResourceListView.swift
// Replaces ui/screens/screenResource/CookingListScreen.kt + ResourceCard.kt

import SwiftUI

struct ResourceListView: View {

    let title: String
    let items: [ResourceItem]
    var navigate: (AppRoute) -> Void
    var dismiss: () -> Void

    @EnvironmentObject var gamificacaoViewModel: GamificacaoViewModel
    @EnvironmentObject var appDependencies: AppDependencies
    @State private var disponibilidadeFiltro: DisponibilidadeFiltro? = nil

    private var filteredItems: [ResourceItem] {
        guard let filtro = disponibilidadeFiltro else { return items }
        return items.filter { item in
            switch filtro {
            case .disponivel: return item.isAvailable(rescuedItems: gamificacaoViewModel.rescuedItems)
            case .resgatar: return !item.isAvailable(rescuedItems: gamificacaoViewModel.rescuedItems)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            HStack {
                Button(action: dismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(16)
                }
                Spacer()
                BeansBalanceView(saldo: gamificacaoViewModel.pontuacao.saldo)
                    .padding(.trailing, 20)
            }
            .padding(.top, 8)

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            // MARK: Filter chips
            HStack(spacing: 8) {
                FilterChip(
                    label: "DISPONÍVEL",
                    systemImage: "leaf",
                    isSelected: disponibilidadeFiltro == .disponivel
                ) {
                    disponibilidadeFiltro = (disponibilidadeFiltro == .disponivel) ? nil : .disponivel
                }
                FilterChip(
                    label: "RESGATAR",
                    systemImage: "circle.fill",
                    isSelected: disponibilidadeFiltro == .resgatar
                ) {
                    disponibilidadeFiltro = (disponibilidadeFiltro == .resgatar) ? nil : .resgatar
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // MARK: Item list
            if filteredItems.isEmpty {
                Spacer()
                Text("Nenhum item encontrado com esses filtros.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(32)
                Spacer()
            } else {
                List {
                    ForEach(filteredItems, id: \.self) { item in
                        ResourceCardRow(item: item, rescuedItems: gamificacaoViewModel.rescuedItems) {
                            navigate(.resourceDetail(
                                item: item,
                                isAvailable: item.isAvailable(rescuedItems: gamificacaoViewModel.rescuedItems)
                            ))
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            gamificacaoViewModel.carregarRescuedItems(repository: appDependencies.gamificacaoRepository)
        }
    }
}

// MARK: - ResourceCard row (ResourceCard.kt port)

struct ResourceCardRow: View {

    let item: ResourceItem
    let rescuedItems: [Int]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Image (local asset, same as ResourceParentCard)
                ZStack(alignment: .topLeading) {
                    if UIImage(named: item.imagens) != nil {
                        Image(item.imagens)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 150)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        item.placeholderColor
                            .frame(width: 120, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if item.isAvailable(rescuedItems: rescuedItems) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .padding(6)
                    } else {
                        HStack(spacing: 3) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.orange)
                            Text("\(item.quantidade)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(6)
                    }
                }
                .frame(width: 120, height: 150)

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.displayTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Text(item.displayDescription.replacingOccurrences(of: "\\n", with: "\n"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(3)

                    Spacer()

                    if !item.type.isEmpty {
                        Text(item.type)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                }
                .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
