// Introduction7View.swift
// 4 screens: notifications → configure → 5-day challenge → INICIAR
// Mirrors ScreenIntroduction_7.kt

import SwiftUI

struct Introduction7View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 4

    init(initialScreen: Int = 1, navigate: @escaping (AppRoute) -> Void) {
        self.initialScreen = initialScreen
        self.navigate = navigate
        _screenNumber = State(initialValue: initialScreen)
    }

    var body: some View {
        IntroductionBackground(isCarioquina: true) {
            VStack(spacing: 0) {
                ScrollView {
                    screenContent
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                footerCard
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Screen content

    @ViewBuilder
    private var screenContent: some View {
        switch screenNumber {
        case 1:
            VStack(spacing: 24) {
                Image(systemName: "bell.badge.fill")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Text(boldText("**Notificações**\n\nFique por dentro de tudo!\nNão perca nenhuma atividade ou conquista."))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineSpacing(6)
            }

        case 2:
            VStack(spacing: 24) {
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Text(boldText("O Feijão no Prato foi pensado para que você passe alguns minutinhos com a gente todos os dias.\n\nEntão, é importante configurar as notificações para não esquecer da gente!"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(6)
            }

        case 3:
            VStack(spacing: 24) {
                Image(systemName: "flag.checkered.2.crossed")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Text("Começamos com um desafio!")
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text(boldText("Como nossa ideia é ter você aqui diariamente, o seu primeiro desafio será entrar no app e realizar as atividades diárias ao longo de **cinco dias**.\n\nSe você completar essa missão, você ganhará **30 feijões**! 🫘"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(6)
            }

        case 4:
            VStack(spacing: 24) {
                Image(systemName: "figure.run")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Text("Tudo pronto!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("Vamos começar sua jornada de transformação com o Feijão no Prato!")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(6)
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footerCard: some View {
        switch screenNumber {
        case 1:
            IntroductionFooterCard(isTransparent: true) {
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 2:
            IntroductionFooterCard {
                Button {
                    openNotificationSettings()
                } label: {
                    Text("CLIQUE AQUI PARA CONFIGURAR")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandOrange)
                        .cornerRadius(12)
                }

                Spacer().frame(height: 12)

                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 3:
            IntroductionFooterCard {
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 4:
            IntroductionFooterCard {
                Button(action: { navigate(.home) }) {
                    Text("INICIAR")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandOrange)
                        .cornerRadius(12)
                }

                Spacer().frame(height: 12)

                // On last screen, arrows are hidden (blend with background)
                IntroductionNavRow(
                    total: totalScreens,
                    current: screenNumber,
                    showArrows: false,
                    onBack: goBack,
                    onNext: { navigate(.home) }
                )
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Navigation

    private func goBack() {
        if screenNumber > 1 {
            screenNumber -= 1
        } else {
            navigate(.introduction6(screen: 2))
        }
    }

    private func goNext() {
        if screenNumber < totalScreens {
            screenNumber += 1
        } else {
            navigate(.home)
        }
    }

    private func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    Introduction7View(navigate: { _ in })
}
