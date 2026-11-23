// ResourcesView.swift
// Replaces ui/screens/resources/ResourcesScreen.kt + TextWithImageResources.kt

import SwiftUI

// MARK: - Main Feira Screen

struct ResourcesView: View {

    var navigate: (AppRoute) -> Void

    @StateObject private var viewModel = ResourcesViewModel()
    @EnvironmentObject var gamificacaoViewModel: GamificacaoViewModel
    @EnvironmentObject var appDependencies: AppDependencies
    @State private var showFilter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 20)

                // MARK: Header
                HStack {
                    Text("Feira")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                    BeansBalanceView(saldo: gamificacaoViewModel.pontuacao.saldo)
                }
                .padding(.horizontal, 16)

                // MARK: Info banner
                if viewModel.showInfoBanner {
                    InfoBannerView(
                        text: "Use seus feijões para trocar por itens exclusivos e benefícios saudáveis.",
                        onClose: { viewModel.showInfoBanner = false }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }

                // MARK: Filter chips (DISPONÍVEL + filter icon — matches Android)
                HStack(spacing: 8) {
                    FilterChip(
                        label: "DISPONÍVEL",
                        systemImage: "leaf",
                        isSelected: viewModel.disponibilidadeFiltro == .disponivel
                    ) {
                        viewModel.toggleDisponibilidadeFiltro(.disponivel)
                    }
                    FilterChip(
                        label: "",
                        systemImage: "line.3.horizontal.decrease.circle",
                        isSelected: !viewModel.categoriasFiltro.isEmpty
                    ) { showFilter = true }
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)

                Spacer().frame(height: 30)

                // MARK: Category rows
                ForEach(viewModel.distinctCategories, id: \.self) { categoria ->  AnyView in
                    let allItems = viewModel.itemsFor(categoria: categoria)
                    let filtered = viewModel.filteredItems(allItems, rescuedItems: gamificacaoViewModel.rescuedItems)
                    guard !filtered.isEmpty else { return AnyView(EmptyView()) }
                    return AnyView(
                        VStack(alignment: .leading, spacing: 0) {
                            // Category header: 20pt regular neutral-gray (matches Android CustomCardViewArrow)
                            Text(categoria)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(Color(white: 0.45))
                                .padding(.leading, 18)
                                .padding(.bottom, 10)

                            // Horizontal card row
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(filtered, id: \.self) { item in
                                        ResourceParentCard(item: item, rescuedItems: gamificacaoViewModel.rescuedItems) {
                                            navigate(.resourceList(title: item.categoria, items: item.listArrayResourceItem))
                                        }
                                    }
                                    Spacer().frame(width: 60)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }

                            Spacer().frame(height: 70)
                        }
                    )
                }

                Spacer().frame(height: 16)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
            gamificacaoViewModel.carregarRescuedItems(repository: appDependencies.gamificacaoRepository)
        }
        .sheet(isPresented: $showFilter) {
            FilterView(
                selected: $viewModel.categoriasFiltro,
                onApply: { newSelection in viewModel.categoriasFiltro = newSelection },
                onDismiss: { showFilter = false }
            )
        }
    }
}

// MARK: - Resource Parent Card (TextWithImageResources)

struct ResourceParentCard: View {

    let item: ResourceItem
    let rescuedItems: [Int]
    let onTap: () -> Void

    private let cardWidth: CGFloat = 159
    private let imageHeight: CGFloat = 120

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image (from local assets, falls back to placeholder color)
                ZStack(alignment: .topLeading) {
                    if UIImage(named: item.imagens) != nil {
                        Image(item.imagens)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: imageHeight)
                            .clipped()
                    } else {
                        item.placeholderColor
                            .frame(width: cardWidth, height: imageHeight)
                    }

                    // Available / cost badge — mirrors TextWithImageResources.kt
                    if item.isAvailable(rescuedItems: rescuedItems) {
                        Image("icon_bean")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(8)
                            .background(Color(red: 0.541, green: 0.741, blue: 0.608).opacity(0.9))
                            .clipShape(Circle())
                            .padding(8)
                    } else {
                        HStack(spacing: 3) {
                            Image("icon_bean")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                            Text("\(item.quantidade)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding(6)
                    }
                }

                Text(item.subcategoria)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .frame(width: cardWidth, alignment: .leading)
            }
            .frame(width: cardWidth)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shared sub-views

struct BeansBalanceView: View {
    let saldo: Int
    // Android: primary_200 = #9E472E (dark brownish-red)
    private let primary200 = Color(red: 0.620, green: 0.278, blue: 0.180)
    var body: some View {
        HStack(spacing: 4) {
            Image("icon_bean")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text(String(format: "%02d", saldo))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(primary200)
        }
    }
}

struct InfoBannerView: View {
    let text: String
    let onClose: () -> Void
    // Android: tertiary_100 = #d4e37b
    private let bannerBackground = Color(red: 0.831, green: 0.890, blue: 0.482)
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.black)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black.opacity(0.6))
            }
        }
        .padding(16)
        .background(bannerBackground)
        .cornerRadius(10)
    }
}

struct FilterChip: View {
    let label: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? Color.brandOrange : Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.brandOrange : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
