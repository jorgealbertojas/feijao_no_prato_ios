// HomeView.swift
// Replaces ui/screens/home/HomeScreen.kt + LevelScreen.kt + CustomCardView

import SwiftUI

// MARK: - HomeView

struct HomeView: View {

    var navigate: (AppRoute) -> Void

    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var gamificacaoViewModel: GamificacaoViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 35)
            ProgressCardView(viewModel: viewModel, navigate: navigate)
            Spacer().frame(height: 2)
            TrailView(viewModel: viewModel, navigate: navigate)
        }
        .onAppear {
            viewModel.loadAll()
            gamificacaoViewModel.carregar()
        }
        .onChange(of: gamificacaoViewModel.pontuacao) { pontuacao in
            viewModel.updateWithGamificacao(
                moduloServidor: pontuacao.ultimoModulo,
                sessaoServidor: pontuacao.ultimoSessao
            )
        }
    }
}

// MARK: - ProgressCardView

struct ProgressCardView: View {

    @ObservedObject var viewModel: HomeViewModel
    var navigate: (AppRoute) -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 106)
            .overlay(cardContent)
            .padding(.horizontal, 32)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private var cardContent: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Level + module + section location
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.brandOrange)

                    let location = "\(viewModel.nivelExibicao), MÓD. \(viewModel.moduloAtual), SEÇÃO \(viewModel.sessaoAtual)"
                    Text(location)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .lineSpacing(0)
                }
                .padding(.bottom, 5)

                Text(viewModel.currentSectionTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer().frame(height: 10)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(white: 0.9))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.3, green: 0.7, blue: 0.4))
                            .frame(width: geo.size.width * CGFloat(viewModel.sessaoPosicao), height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.leading, 10)
            .padding(.vertical, 10)

            Spacer().frame(width: 16)

            // Menu icon
            Image(systemName: "list.bullet.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 60)
                .foregroundColor(.brandOrange)
                .padding(.trailing, 20)
                .onTapGesture {
                    navigate(.screenModule)
                }
        }
        .padding(1)
    }
}

// MARK: - TrailView

struct TrailView: View {

    @ObservedObject var viewModel: HomeViewModel
    var navigate: (AppRoute) -> Void

    @State private var selectedSection: SectionItemUi? = nil
    @State private var showBlockedAlert = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.trailItems) { item in
                        TrailNodeRow(
                            item: item,
                            onTap: { handleTap(item) }
                        )
                        .id(item.sectionItem.globalIndex)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 50)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .onAppear {
                let idx = viewModel.scrollToGlobalIndex
                if idx > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo(idx, anchor: .center)
                        }
                    }
                }
            }
            .onChange(of: viewModel.scrollToGlobalIndex) { idx in
                if idx > 0 {
                    withAnimation { proxy.scrollTo(idx, anchor: .center) }
                }
            }
        }
        .sheet(item: $selectedSection) { section in
            SectionDialogSheet(section: section, onNavigate: {
                selectedSection = nil
                viewModel.saveBeforeNavigation(section: section)
                navigate(.screenSection)
            }, onCancel: {
                selectedSection = nil
            })
        }
        .alert("Ops!", isPresented: $showBlockedAlert) {
            Button("OK") {}
        } message: {
            Text("Você ainda tem que terminar a sessão anterior")
        }
    }

    private func handleTap(_ item: TrailItemState) {
        if item.isClickable {
            selectedSection = item.sectionItem
        } else if item.isBlocked {
            showBlockedAlert = true
        }
    }
}

// MARK: - TrailNodeRow

struct TrailNodeRow: View {

    let item: TrailItemState
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.showDivider {
                TrailDividerView(label: item.dividerLabel, moduleNumber: item.sectionItem.moduleIndex)
            }

            HStack(alignment: .center) {
                if item.showHereIndicator {
                    hereIndicator
                }

                sectionNode
            }
            .frame(maxWidth: .infinity, alignment: positionAlignment)
        }
    }

    private var positionAlignment: Alignment {
        switch item.sectionItem.section.position {
        case "center": return .center
        case "right": return .trailing
        default: return .leading
        }
    }

    private var hereIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.brandOrange)
                .font(.system(size: 12))
            Text("Você está aqui")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.brandOrange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.brandOrange.opacity(0.1))
        .clipShape(Capsule())
        .padding(.bottom, -6)
    }

    private var sectionNode: some View {
        let size = CGFloat(item.sectionItem.section.imageSize)
        let isCircle = !item.isSpecialModule
        let alpha: Double = item.imageState == .locked ? 0.3 : 0.9

        return Group {
            if item.isSpecialModule {
                specialModuleView(size: size)
            } else {
                circleView(size: size)
            }
        }
        .opacity(alpha)
        .onTapGesture(perform: onTap)
    }

    private func circleView(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(nodeColor)
                .frame(width: size, height: size)

            if item.imageState != .locked {
                Circle()
                    .strokeBorder(nodeColor.opacity(0.6), lineWidth: 2)
                    .frame(width: size, height: size)
            }

            Text("\(item.sectionItem.sessaoDaVez)")
                .font(.system(size: size * 0.28, weight: .bold))
                .foregroundColor(nodeTextColor)
        }
    }

    private func specialModuleView(size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(specialColor.opacity(0.15))
                .frame(width: size + 20, height: size + 20)

            Image(systemName: specialSymbol)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.5, height: size * 0.5)
                .foregroundColor(specialColor)

            Text("S\(item.sectionItem.sessaoDaVez)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(specialColor)
                .offset(y: size * 0.3)
        }
    }

    private var nodeColor: Color {
        switch item.imageState {
        case .completed: return Color(red: 0.3, green: 0.72, blue: 0.42)
        case .inProgress: return Color(red: 0.98, green: 0.75, blue: 0.1)
        case .available: return .white
        case .locked: return Color(white: 0.85)
        }
    }

    private var nodeTextColor: Color {
        switch item.imageState {
        case .completed: return .white
        case .inProgress: return Color(red: 0.5, green: 0.35, blue: 0.0)
        case .available, .locked: return Color(white: 0.5)
        }
    }

    private var specialColor: Color {
        switch item.sectionItem.moduleIndex {
        case 9: return .brandOrange
        case 10: return Color(red: 0.6, green: 0.35, blue: 0.15)
        default: return Color(red: 0.2, green: 0.6, blue: 0.3)
        }
    }

    private var specialSymbol: String {
        switch item.sectionItem.moduleIndex {
        case 9: return "checkmark.seal.fill"
        case 10: return "person.2.fill"
        default: return "figure.walk"
        }
    }
}

// MARK: - TrailDividerView

struct TrailDividerView: View {
    let label: String
    let moduleNumber: Int

    var body: some View {
        if !label.isEmpty {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color(white: 0.8))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                VStack(spacing: 0) {
                    Text(label)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(white: 0.45))
                    Text("MÓD. \(moduleNumber)")
                        .font(.system(size: 10))
                        .foregroundColor(Color(white: 0.6))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(white: 0.95))
                .clipShape(Capsule())
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - SectionDialogSheet

struct SectionDialogSheet: View {
    let section: SectionItemUi
    var onNavigate: () -> Void
    var onCancel: () -> Void

    private var subTitleText: String {
        switch section.sessaoDaVez {
        case 1: return "Introdução teórica"
        case 2: return "Aprofundamento"
        case 3: return "Conexão com a prática"
        case 4: return "Prática"
        case 5: return "Avaliação"
        case 6: return "Revisão"
        case 7: return "Extra"
        default: return "Seção"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color(white: 0.8))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            VStack(spacing: 6) {
                Text(section.section.name.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.brandOrange)

                Text(section.section.title)
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.18))

                Text(subTitleText)
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.5))
                    .padding(.top, 2)
            }
            .padding(.horizontal, 20)

            if !section.section.body.isEmpty {
                Text(section.section.body)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(white: 0.4))
                    .padding(.horizontal, 24)
            }

            HStack(spacing: 12) {
                Button("Cancelar", action: onCancel)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.95))
                    .cornerRadius(12)

                Button("INICIAR SEÇÃO", action: onNavigate)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.brandOrange)
                    .cornerRadius(12)
            }
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 20)

            Spacer()
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    HomeView(navigate: { _ in })
        .environmentObject(GamificacaoViewModel())
}
