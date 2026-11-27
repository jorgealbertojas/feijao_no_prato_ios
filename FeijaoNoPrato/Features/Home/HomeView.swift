// HomeView.swift
// Replaces ui/screens/home/HomeScreen.kt + LevelScreen.kt + CustomCardView

import SwiftUI

// MARK: - HomeView

struct HomeView: View {

    var navigate: (AppRoute) -> Void

    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var gamificacaoViewModel: GamificacaoViewModel

    // Android neutral_100 / carioquina_introdution = #F1ECE1
    private static let trailBackground = Color(red: 0.945, green: 0.925, blue: 0.882)

    var body: some View {
        VStack(spacing: 0) {
            HomeHeaderView(saldo: gamificacaoViewModel.pontuacao.saldo)
            ProgressCardView(viewModel: viewModel, navigate: navigate)
            Spacer().frame(height: 2)
            TrailView(viewModel: viewModel, navigate: navigate)
        }
        .background(HomeView.trailBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadAll()
        }
        .onChange(of: gamificacaoViewModel.pontuacao) { pontuacao in
            viewModel.updateWithGamificacao(
                moduloServidor: pontuacao.ultimoModulo,
                sessaoServidor: pontuacao.ultimoSessao
            )
        }
    }
}

// MARK: - HomeHeaderView

private struct HomeHeaderView: View {
    let saldo: Int

    var body: some View {
        HStack {
            // Logo — mirrors EasterEggIcon (icon_main icon + icon_main_name text)
            HStack(spacing: 6) {
                Image("icon_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("feijão\nno prato")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                    .lineSpacing(0)
            }

            Spacer()

            // Bean count — mirrors icon_point + points display in BottomBar.kt
            HStack(spacing: 4) {
                Image("icon_bean")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                Text("\(saldo)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

// MARK: - ProgressCardView

struct ProgressCardView: View {

    @ObservedObject var viewModel: HomeViewModel
    var navigate: (AppRoute) -> Void

    var body: some View {
        cardContent
            .frame(maxWidth: .infinity)
            .frame(minHeight: 106)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 32)
    }

    private var cardContent: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Level + module + section location
                HStack(spacing: 4) {
                    Image("icon_localization")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 16)

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

            // Menu icon — mirrors icon_menu_new at 74x110dp in Android CustomCardView
            Image("icon_menu_new")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 60)
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

            VStack(alignment: .leading, spacing: 0) {
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

    // Android: CustomCardViewPosition — white card + down triangle
    private var hereIndicator: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.brandOrange)
                        .font(.system(size: 14))
                    Text("Onde estou")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                }
                Text(item.sectionItem.section.name)
                    .font(.system(size: 18))
                    // Android primary_300 = #c64b4e
                    .foregroundColor(Color(red: 0.776, green: 0.294, blue: 0.306))
            }
            .padding(10)
            .background(Color.white)
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)

            TriangleDown()
                .fill(Color.white)
                .frame(width: 16, height: 10)
                .padding(.leading, 20)
        }
        .padding(.bottom, 2)
    }

    private var sectionNode: some View {
        let size = CGFloat(item.sectionItem.section.imageSize)
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

    // Mirrors LevelScreen.kt: imagem3=completed(green), imagem2=inProgress(yellow), imagem1=available/locked
    private func circleView(size: CGFloat) -> some View {
        let imageName: String
        switch item.imageState {
        case .completed:  imageName = "imagem3"
        case .inProgress: imageName = "imagem2"
        case .available, .locked: imageName = "imagem1"
        }
        return Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }

    // Mirrors LevelScreen.kt: moduleIndex 9/10/11 use character images, no circle clip, ContentScale.Fit
    private func specialModuleView(size: CGFloat) -> some View {
        let imageName: String
        switch item.sectionItem.moduleIndex {
        case 9:  imageName = "icon_fixando_new"
        case 10: imageName = "icon_feijuca_convida"
        default: imageName = "icon_praticando"
        }
        return Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size + 20, height: size + 20)
    }
}

// MARK: - TrailDividerView (hidden — Android does not show module dividers in the trail)

struct TrailDividerView: View {
    let label: String
    let moduleNumber: Int
    var body: some View { EmptyView() }
}

// MARK: - SectionDialogSheet

struct SectionDialogSheet: View {
    let section: SectionItemUi
    var onNavigate: () -> Void
    var onCancel: () -> Void

    // Android strings.xml: dialog_title_sessao_1..7
    private var subTitleText: String {
        switch section.sessaoDaVez {
        case 1: return "Ao concluir esta seção, você completa 14% do módulo."
        case 2: return "Ao concluir esta seção, você completa 28% do módulo."
        case 3: return "Ao concluir esta seção, você completa 42% do módulo."
        case 4: return "Ao concluir esta seção, você completa 56% do módulo."
        case 5: return "Ao concluir esta seção, você completa 70% do módulo."
        case 6: return "Ao concluir esta seção, você completa 84% do módulo."
        case 7: return "Ao concluir esta seção, você completa 100% do módulo."
        default: return "Você já conclui 25% da sessão. \n Preparado para continuar?"
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
                Button(action: onCancel) {
                    Text("Cancelar")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(white: 0.95))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)

                Button(action: onNavigate) {
                    Text("ACESSAR SEÇÃO")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandOrange)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
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
