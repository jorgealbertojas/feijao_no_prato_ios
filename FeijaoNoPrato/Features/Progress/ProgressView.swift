// ProgressView.swift
// Replaces ui/screens/progress/ProgressScreen.kt + FullWidthCardProgress.kt +
//          TwoCardRow.kt + TwoCardRowNew.kt + PointsHistoryCard.kt + TextWithImage.kt

import SwiftUI

// MARK: - ProgressView_

struct ProgressView_: View {

    @StateObject private var viewModel = ProgressViewModel()
    @EnvironmentObject private var gamificacaoViewModel: GamificacaoViewModel
    var navigate: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "Progresso" title — mirrors the Column overlay in ProgressScreen.kt
            Text("Progresso")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 20) {
                    // Full-width progress card (Progresso Total)
                    ProgressoTotalCard(
                        progressoPercent: viewModel.progressoPercent,
                        modulosCompletos: viewModel.modulosCompletos,
                        navigate: navigate
                    )

                    // Two cards: Feijões + Pratos avaliados (26pt gap, left card taps → history)
                    HStack(spacing: 26) {
                        StatCard(
                            value: "\(gamificacaoViewModel.pontuacao.saldo)",
                            label: "Feijões\nconquistados",
                            assetImage: "icon_bean",
                            onTap: { navigate(.history) }
                        )
                        StatCard(
                            value: "\(viewModel.totalCamera)",
                            label: "Pratos\navaliados",
                            icon: "camera.fill",
                            iconColor: .brandOrange
                        )
                    }

                    // Alimentação history card
                    AlimentacaoHistoryCard(scores: viewModel.alimentacaoScores)

                    // Two cards: Seções completas + Desafios (26pt gap, no tap)
                    HStack(spacing: 26) {
                        StatCard(
                            value: "\(viewModel.sessoesCompletas)",
                            label: "Seções\nCompletas"
                        )
                        StatCard(
                            value: "\(viewModel.desafiosCompletos)",
                            label: "Desafios"
                        )
                    }

                    Spacer().frame(height: 60)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.carregar()
        }
    }
}

// MARK: - ProgressoTotalCard

private struct ProgressoTotalCard: View {

    let progressoPercent: Int
    let modulosCompletos: Int
    var navigate: (AppRoute) -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 130)
            .overlay(cardContent)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            .onTapGesture { navigate(.moduleDetail(id: 1)) }
    }

    private var cardContent: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Progresso Total")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 10)

                Text("\(progressoPercent)%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.85, green: 0.5, blue: 0.1))

                Spacer().frame(height: 4)

                Text("Percorrido")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.5))

                Spacer().frame(height: 10)
            }
            .padding(.leading, 16)

            Spacer()

            FlowerProgressView(modulosCompletos: modulosCompletos)
            .frame(width: 70, height: 70)
            .padding(.trailing, 16)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - FlowerProgressView (replaces FlowerModules.kt)
// Mirrors FlowerModules.kt: 0→petala1, 1→petala2, … 9→petala10

private struct FlowerProgressView: View {

    let modulosCompletos: Int

    var body: some View {
        let imageIndex = modulosCompletos.clamped(to: 0...9)
        Image("petala\(imageIndex + 1)")
            .resizable()
            .scaledToFit()
            .animation(.easeInOut(duration: 0.4), value: modulosCompletos)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - StatCard

private struct StatCard: View {

    let value: String
    let label: String
    var icon: String? = nil
    var iconColor: Color = .clear
    var assetImage: String? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .overlay(cardContent)
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            .onTapGesture { onTap?() }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                if let assetImage {
                    Image(assetImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                } else if let icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(iconColor)
                }
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.top, 16)

            Spacer().frame(height: 10)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.5))
                .lineSpacing(2)

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - AlimentacaoHistoryCard (replaces PointsHistoryCard.kt)

private struct AlimentacaoHistoryCard: View {

    let scores: [Int]

    @State private var showInfo = false

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .overlay(cardContent)
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            .alert("Sobre a pontuação", isPresented: $showInfo) {
                Button("Fechar") {}
            } message: {
                Text("Aqui você acompanha a evolução da sua alimentação em três momentos da jornada. Lembre-se: quanto mais perto de 100, melhor!\n\nEssa pontuação mostra como está sua alimentação com base nas respostas do questionário.")
            }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("Como está sua alimentação?")
                    .font(.system(size: 15))
                    .foregroundColor(Color(white: 0.45))
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(Color(white: 0.6))
                        .font(.system(size: 16))
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)

            Spacer().frame(height: 14)

            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    let score = index < scores.count ? scores[index] : 0
                    VStack(spacing: 2) {
                        Text("\(index + 1)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text("\(score)")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)

                    if index < 2 {
                        Rectangle()
                            .fill(Color(white: 0.8))
                            .frame(width: 1, height: 40)
                    }
                }
            }
        }
    }
}

// MARK: - ModuleDetailView (replaces ModuleDetailScreen.kt)

struct ModuleDetailView: View {

    var dismiss: () -> Void

    @StateObject private var viewModel = ProgressViewModel()

    private let desafios = Array(1...8)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Desafios")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                // balance chevron
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(desafios, id: \.self) { modulo in
                        DesafioRowView(
                            moduleNumber: modulo,
                            status: viewModel.statusDoDesafio(moduleNumber: modulo),
                            enabled: viewModel.desafioAlcancado(moduleNumber: modulo)
                        )
                    }
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(white: 0.97).ignoresSafeArea())
        .onAppear { viewModel.carregar() }
    }
}

// MARK: - DesafioRowView (replaces SessionRow composable)

private struct DesafioRowView: View {

    let moduleNumber: Int
    let status: ProgressViewModel.DesafioStatus
    let enabled: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .overlay(rowContent)
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
            .opacity(enabled ? 1 : 0.65)
            .padding(.top, 10)
    }

    private var rowContent: some View {
        HStack {
            Text("Módulo \(moduleNumber)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.system(size: 20))
                Text(statusLabel)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                if enabled {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(white: 0.6))
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var statusIcon: String {
        switch status {
        case .concluido: return "checkmark.circle.fill"
        case .emAndamento: return "circle.dotted"
        case .naoIniciado: return "lock.fill"
        }
    }

    private var statusColor: Color {
        switch status {
        case .concluido: return Color(red: 0.3, green: 0.72, blue: 0.42)
        case .emAndamento: return .brandOrange
        case .naoIniciado: return Color(white: 0.6)
        }
    }

    private var statusLabel: String {
        switch status {
        case .concluido: return "Concluído"
        case .emAndamento: return "Em andamento"
        case .naoIniciado: return "Não iniciado"
        }
    }
}

#Preview {
    ProgressView_(navigate: { _ in })
        .environmentObject(GamificacaoViewModel())
}
