// Introduction7View.swift
// 4 screens — mirrors ScreenIntroduction_7.kt
// Screen 1: balloon card "Ótimo!" + icon_e1 (250dp)
// Screen 2: icon_logo (160dp) + notification config
// Screen 3: icon_intro_fb + 5-day challenge
// Screen 4: balloon card "Chegou o grande momento..." + icon_f2 (250dp) + INICIAR button

import SwiftUI

struct Introduction7View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 4

    // Android primary_100 = #CE7257
    private let primary100 = Color(red: 0.808, green: 0.447, blue: 0.341)

    init(initialScreen: Int = 1, navigate: @escaping (AppRoute) -> Void) {
        self.initialScreen = initialScreen
        self.navigate = navigate
        _screenNumber = State(initialValue: initialScreen)
    }

    var body: some View {
        IntroductionBackground {
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
            // Android: Introduction_7_1 — balloon card + icon_e1 (250dp)
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text(boldText("Ótimo! Agora que tenho seu perfil alimentar, é hora dos últimos preparativos antes de embarcar."))
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .lineSpacing(4)

                    Text("Vamos começar?")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        // Android primary_200 = #9E472E
                        .foregroundColor(Color(red: 0.620, green: 0.278, blue: 0.180))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                )

                TriangleDown()
                    .fill(Color.white)
                    .frame(width: 32, height: 18)

                Spacer().frame(height: 40)

                Image("icon_e1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            .padding(.horizontal, 4)

        case 2:
            // Android: Introduction_7_2 — icon_logo (160dp) + title
            VStack(spacing: 20) {
                Spacer().frame(height: 10)
                Image("icon_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)

                Text("CONFIGURAÇÃO DAS NOTIFICAÇÕES")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
            }
            .padding(26)

        case 3:
            // Android: Introduction_7_3 — icon_intro_fb (305×250dp)
            VStack(spacing: 20) {
                Spacer().frame(height: 35)
                Image("icon_intro_fb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 305, height: 250)
            }
            .padding(26)

        case 4:
            // Android: Introduction_7_5 — balloon card + icon_f2 (250dp)
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(boldText("Chegou o grande momento: hora de começar sua jornada!\n\"Você pode seguir agora mesmo para a primeira seção ou voltar em outro momento.\"\nEstou te esperando!"))
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                )

                TriangleDown()
                    .fill(Color.white)
                    .frame(width: 32, height: 18)

                Spacer().frame(height: 40)

                Image("icon_f2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            .padding(.horizontal, 4)

        default:
            EmptyView()
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footerCard: some View {
        switch screenNumber {

        case 1:
            // Transparent footer with arrows visible
            IntroductionFooterCard(isTransparent: true) {
                IntroductionNavRow(
                    total: totalScreens, current: screenNumber,
                    onBack: goBack, onNext: goNext
                )
            }

        case 2:
            // White footer: subtitle text + "CLIQUE AQUI PARA CONFIGURAR" button + arrows
            IntroductionFooterCard {
                Text(boldText("O Feijão no Prato foi pensado para que você passe alguns minutinhos com a gente todos os dias. Então, é importante configurar as notificações para não esquecer da gente!"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(4)

                Spacer().frame(height: 10)

                Button {
                    openNotificationSettings()
                } label: {
                    Text("CLIQUE AQUI PARA CONFIGURAR")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(primary100)
                        .cornerRadius(8)
                }

                Spacer().frame(height: 10)

                IntroductionNavRow(
                    total: totalScreens, current: screenNumber,
                    onBack: goBack, onNext: goNext
                )
            }

        case 3:
            // White footer: title "Começamos com um desafio!" + subTitle + arrows
            IntroductionFooterCard {
                Text("Começamos com um desafio!")
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

                Spacer().frame(height: 16)

                Text(boldText("Como nossa ideia é ter você aqui diariamente, o seu primeiro desafio será entrar no app e realizar as atividades diárias ao longo de cinco dias. \n Se você completar essa missão, você ganhará 30 feijões!"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(4)

                Spacer().frame(height: 10)

                IntroductionNavRow(
                    total: totalScreens, current: screenNumber,
                    onBack: goBack, onNext: goNext
                )
            }

        case 4:
            // Transparent footer: "INICIAR" button + empty arrow circles (showArrows: false)
            IntroductionFooterCard(isTransparent: true) {
                Button {
                    navigate(.home)
                } label: {
                    Text("INICIAR")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(primary100)
                        .cornerRadius(8)
                }

                Spacer().frame(height: 10)

                IntroductionNavRow(
                    total: totalScreens, current: screenNumber,
                    showArrows: false,
                    onBack: goBack, onNext: goNext
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
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    Introduction7View(navigate: { _ in })
}
