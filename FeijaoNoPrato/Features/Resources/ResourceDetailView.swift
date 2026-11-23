// ResourceDetailView.swift
// Replaces ui/screens/screenResource/ScreenResource.kt + ConfirmResgateScreen.kt

import SwiftUI

struct ResourceDetailView: View {

    let item: ResourceItem
    let isAvailable: Bool
    var dismiss: () -> Void
    var navigate: (AppRoute) -> Void

    @EnvironmentObject var gamificacaoViewModel: GamificacaoViewModel
    @EnvironmentObject var appDependencies: AppDependencies

    @State private var showConfirmRescate = false
    @State private var rescateConfirmado = false

    private var recursoDisponivel: Bool {
        isAvailable || rescateConfirmado || item.id == 0 ||
        gamificacaoViewModel.rescuedItems.contains(item.id)
    }

    var body: some View {
        ZStack {
            // MARK: Main content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(20)
                    }
                    Spacer()
                    Text("Meus feijões")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                    BeansBalanceView(saldo: gamificacaoViewModel.pontuacao.saldo)
                        .padding(.trailing, 20)
                }
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Image placeholder
                        item.placeholderColor
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                Image(systemName: typeIcon)
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.6))
                            )
                            .padding(.horizontal, 16)

                        Spacer().frame(height: 20)

                        // Title
                        Text(item.displayTitle)
                            .font(.system(size: 26, weight: .bold))
                            .padding(.horizontal, 24)

                        Spacer().frame(height: 8)

                        // Type badge
                        if !item.type.isEmpty {
                            Text(item.type)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .padding(.horizontal, 24)
                                .padding(.top, 4)
                        }

                        Spacer().frame(height: 12)

                        // Description
                        if !item.displayDescription.isEmpty {
                            if recursoDisponivel {
                                Text(item.displayDescription.replacingOccurrences(of: "\\n", with: "\n"))
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 24)
                            } else {
                                LockedDescriptionView(text: item.displayDescription)
                                    .padding(.horizontal, 24)
                            }
                        }

                        Spacer().frame(height: 24)

                        // Cost or available indicator
                        if recursoDisponivel {
                            HStack(spacing: 8) {
                                Image(systemName: "bag")
                                    .foregroundColor(.primary)
                                Text("Disponível")
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 24)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Resgate por:")
                                    .font(.system(size: 15, weight: .semibold))
                                HStack(spacing: 6) {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.brandOrange)
                                        .font(.system(size: 14))
                                    Text("\(item.quantidade) Feijões")
                                        .font(.system(size: 15))
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        Spacer().frame(height: 24)

                        // Action buttons
                        VStack(spacing: 12) {
                            if recursoDisponivel {
                                if item.tipos != "Texto no app" && !item.link.isEmpty {
                                    Button {
                                        navigate(.webView(url: item.link))
                                    } label: {
                                        Text("ABRIR")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 48)
                                            .background(Color.brandOrange)
                                            .cornerRadius(50)
                                    }
                                }

                                // Share button
                                if ["Site", "Áudio", "Video", "Vídeo"].contains(item.tipos),
                                   item.compartilhar == "1",
                                   !item.link.isEmpty {
                                    ShareLink(item: URL(string: item.link) ?? URL(string: "https://")!) {
                                        Text("COMPARTILHAR")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.brandOrange)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 48)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 50)
                                                    .stroke(Color.brandOrange, lineWidth: 1)
                                            )
                                    }
                                }
                            } else {
                                Button {
                                    showConfirmRescate = true
                                } label: {
                                    Text("RESGATAR")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(Color.brandOrange)
                                        .cornerRadius(50)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .background(Color(.systemBackground))

            // MARK: Confirm rescue overlay
            if showConfirmRescate {
                ConfirmRescateView(
                    recursoNome: item.displayTitle,
                    feijoes: item.quantidade,
                    placeholderColor: item.placeholderColor,
                    onConfirmar: {
                        let sucesso = gamificacaoViewModel.registrarRescue(
                            numero: item.id,
                            quantidade: item.quantidade,
                            repository: appDependencies.gamificacaoRepository
                        )
                        if sucesso {
                            rescateConfirmado = true
                        }
                        showConfirmRescate = false
                    },
                    onCancelar: { showConfirmRescate = false }
                )
            }
        }
        .navigationBarHidden(true)
    }

    private var typeIcon: String {
        switch item.tipos {
        case "Video", "Vídeo": return "play.circle"
        case "Áudio": return "headphones"
        case "Site": return "safari"
        default: return "doc.text"
        }
    }
}

// MARK: - Locked content view

private struct LockedDescriptionView: View {
    let text: String
    var body: some View {
        ZStack {
            Text(text.replacingOccurrences(of: "\\n", with: "\n"))
                .font(.system(size: 15))
                .blur(radius: 4)
            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                Text("Resgate para acessar")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Confirm Rescate view (ConfirmResgateScreen.kt port)

struct ConfirmRescateView: View {

    let recursoNome: String
    let feijoes: Int
    let placeholderColor: Color
    let onConfirmar: () -> Void
    let onCancelar: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("Confirmação de\ncompra")
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("RECURSO:")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    // Resource card preview
                    HStack(spacing: 12) {
                        placeholderColor
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(recursoNome)
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Text("Resgate por:")
                        .font(.system(size: 16, weight: .semibold))

                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.brandOrange)
                            .font(.system(size: 14))
                        Text(String(format: "%02d Feijões", feijoes))
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .padding(20)

                Spacer().frame(height: 8)

                Button(action: onConfirmar) {
                    Text("CONFIRMAR RESGATE")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.brandOrange)
                        .cornerRadius(50)
                }
                .padding(.horizontal, 20)

                Button(action: onCancelar) {
                    Text("CANCELAR")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 16)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 24)
        }
    }
}
