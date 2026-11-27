// ScreenSectionView.swift
// Ports ScreenSection.kt — content delivery screen with paged dynamic content

import SwiftUI

struct ScreenSectionView: View {

    var navigate: (AppRoute) -> Void
    var dismiss: () -> Void

    @StateObject private var viewModel = ScreenSectionViewModel()
    @EnvironmentObject private var gamificacaoViewModel: GamificacaoViewModel

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch viewModel.loadState {
            case .loading, .idle:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .error(let msg):
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Não foi possível carregar o conteúdo.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                    Text(msg)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Tentar novamente") { viewModel.load() }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.brandOrange)
                }
                .padding(32)

            case .loaded:
                contentView
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.load() }
        .alert("Parabéns!", isPresented: $viewModel.sessionConcluded) {
            Button("OK") { dismiss() }
        } message: {
            Text("Você concluiu esta sessão!")
        }
        .sheet(isPresented: $viewModel.showFeedback) {
            FeedbackSheet(
                isCorrect: viewModel.feedbackIsCorrect,
                feedbackText: viewModel.feedbackText,
                onContinue: {
                    // Award [FIXANDO] points when answer is correct, mirroring Android ScreenSection.kt
                    if viewModel.feedbackIsCorrect,
                       let page = viewModel.currentPage,
                       let pergunta = page.itens?.first(where: { $0.tipo == "Pergunta" }),
                       pergunta.personalizacao == "[FIXANDO]" {
                        let ref = "\(viewModel.sessaoAtual + 1)_\(viewModel.currentPageIndex)"
                        gamificacaoViewModel.adicionarPontos(
                            modulo_numero: String(viewModel.moduloAtual),
                            modulo: "0",
                            atividade: "[FIXANDO]",
                            referenciaUnica: ref
                        )
                    }
                    viewModel.dismissFeedbackAndAdvance()
                }
            )
            .presentationDetents([.fraction(0.4)])
        }
    }

    // MARK: - Content

    private var contentView: some View {
        VStack(spacing: 0) {

            // Header
            headerView

            // Module/Section label
            Text(viewModel.moduloLabel)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(1.5)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            // Scrollable page content + floating bottom bar overlay
            ZStack(alignment: .bottom) {
                ScrollView {
                    if let page = viewModel.currentPage, let items = page.itens {
                        DynamicContentView(
                            items: items,
                            imageBaseURL: viewModel.imageBaseURL,
                            selectedOption: viewModel.selectedOption,
                            tempCorrectCount: viewModel.tempCorrectCount,
                            onOptionSelected: { viewModel.selectedOption = $0 },
                            navigate: navigate,
                            onBotaoExtra: { personalizacao in
                                if personalizacao.contains("[OPEN_FEIRA") {
                                    // Extract category from [OPEN_FEIRA_Cereais] → "Cereais"
                                    // [OPEN_FEIRA] or [OPEN_FEIRA (no underscore) → no filter
                                    let categoria = personalizacao
                                        .components(separatedBy: "OPEN_FEIRA_").dropFirst().first?
                                        .components(separatedBy: "]").first ?? ""
                                    navigate(.resourcesFiltered(categoria: categoria))
                                } else if personalizacao.contains("[OPEN_IA]") {
                                    navigate(.food)
                                } else if personalizacao == "[OPEN_MENU]" {
                                    dismiss()
                                } else if personalizacao == "[NEXT_SECTION]" {
                                    dismiss()
                                }
                            }
                        )
                    }
                    // Extra padding so last content is not hidden behind floating bar
                    Spacer().frame(height: 88)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom navigation — floats over content with gradient
                bottomBar
            }
        }
    }

    // MARK: - Header (X button + progress bar)

    private var headerView: some View {
        VStack(spacing: 6) {
            HStack {
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .padding(.leading, 16)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.957, green: 0.910, blue: 0.882)) // neutral_new #F4E8E1
                            .frame(height: 12)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.122, green: 0.757, blue: 0.420)) // green_200 #1fc16b
                            .frame(width: geo.size.width * CGFloat(viewModel.progress), height: 12)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 12)
            }
            .frame(height: 44)
            .padding(.top, 8)
        }
    }

    // MARK: - Bottom bar (prev/next/CONFIRMAR/SEGUIR)

    private var bottomBar: some View {
        HStack(spacing: 12) {

            if viewModel.prevVisible {
                Button(action: { viewModel.goPrev() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.brandOrange)
                        .frame(width: 48, height: 48)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.brandOrange, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }

            if viewModel.nextVisible {
                let desc = viewModel.nextDescricao.uppercased()
                let isConfirmar = desc == "CONFIRMAR"
                let isSeguir = desc.contains("SELECT_DOUBLE")
                let isProximo = desc == "PRÓXIMO"
                // Android: "Próximo" always shows circle arrow icon, never text
                let label = isSeguir ? "SEGUIR" : (isConfirmar ? "CONFIRMAR" : desc)
                let confirmarDisabled = isConfirmar && viewModel.selectedOption == nil

                if isProximo {
                    Spacer()
                    Button(action: { viewModel.goNext() }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color.brandOrange)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: {
                        if isConfirmar {
                            viewModel.confirmarResposta()
                        } else {
                            viewModel.goNext()
                        }
                    }) {
                        Text(label)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(confirmarDisabled ? Color.brandOrange.opacity(0.4) : Color.brandOrange)
                            .cornerRadius(50)
                    }
                    .disabled(confirmarDisabled)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(0),
                    Color(.systemBackground).opacity(0.85),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - FeedbackSheet

private struct FeedbackSheet: View {
    let isCorrect: Bool
    let feedbackText: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 8)

            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(isCorrect ? .green : .red)

            Text(isCorrect ? "Correto!" : "Incorreto!")
                .font(.system(size: 20, weight: .bold))

            Text(feedbackText)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)

            Button(action: onContinue) {
                Text(isCorrect ? "CONTINUAR" : "TENTAR NOVAMENTE")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(isCorrect ? Color.green : Color.brandOrange)
                    .cornerRadius(50)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color(.systemBackground))
    }
}
