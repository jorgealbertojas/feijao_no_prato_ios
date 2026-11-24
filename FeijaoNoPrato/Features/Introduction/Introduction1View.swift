// Introduction1View.swift
// 6 screens: welcome → nutrition → 120-day journey → balloon x2 → bean selection
// Mirrors ScreenIntroduction_1.kt

import SwiftUI

struct Introduction1View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int
    @State private var selectedBean: String? = nil

    private let totalScreens = 6

    init(initialScreen: Int = 1, navigate: @escaping (AppRoute) -> Void) {
        self.initialScreen = initialScreen
        self.navigate = navigate
        _screenNumber = State(initialValue: initialScreen)
    }

    var body: some View {
        IntroductionBackground(isWhite: screenNumber == 7) {
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
                // Android uses R.drawable.introduction_app (200dp) = feijão colorido
                Image("icon_logo")
                    .resizable().scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 30)
                Text("Boas vindas ao\nFeijão no Prato!")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(8)
                Text("Transforme sua alimentação com o Guia Alimentar para a População Brasileira.")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(6)
            }

        case 2:
            // Android: Introduction_1_2 shows R.drawable.parabens_atitude (305×250dp)
            // text goes into the footer card (title + subTitle), not here
            VStack {
                Spacer().frame(height: 50)
                Image("parabens_atitude")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 305, height: 250)
            }

        case 3:
            BalloonCard(
                text: "**Mudar de hábitos não é fácil, mas vamos te ajudar.**\n\nSerá uma jornada de **120 dias que irão transformar sua alimentação.** Sem contar calorias, sem dietas da moda e sem metas impossíveis.",
                icon: "calendar.badge.clock",
                iconColor: Color.brandOrange
            )

        case 4:
            VStack(spacing: 20) {
                Image(systemName: "figure.walk.circle.fill")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.brandOrange)
                Text(boldText("**E você terá um amigo nesta viagem...**\n\nCarioquinha vai te guiar pelos 120 dias desta jornada de transformação!"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(6)
            }
            .padding(24)

        case 5:
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .resizable().scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.brandOrange)
                Text(boldText("**A Carioquinha** vai te apresentar conteúdos, desafios e dicas ao longo da jornada.\n\nEla fica feliz quando você come feijão! 🫘"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(6)
            }
            .padding(24)

        case 6:
            VStack(spacing: 24) {
                Text("Escolha o seu feijão favorito!")
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

                HStack(spacing: 16) {
                    ForEach(["Carioca", "Preto", "Branco"], id: \.self) { bean in
                        BeanOptionCard(label: bean, isSelected: selectedBean == bean) {
                            selectedBean = bean
                        }
                    }
                }
            }
            .padding(16)

        default:
            EmptyView()
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footerCard: some View {
        switch screenNumber {
        case 1:
            IntroductionFooterCard {
                // Android shows "Vamos começar?" as title in the footer card
                Text("Vamos começar?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .padding(.bottom, 8)

                Button {
                    screenNumber = 2
                } label: {
                    Text("COMEÇAR")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandOrange)
                        .cornerRadius(12)
                }

                IntroductionNavRow(total: totalScreens, current: screenNumber, showArrows: false, onBack: goBack, onNext: goNext)
            }

        case 2:
            // Android footer: title + subTitle text + nav row
            IntroductionFooterCard {
                Text("Ter uma boa alimentação é uma das melhores decisões que você pode tomar.")
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(6)
                    .padding(.bottom, 12)
                Text(boldText("**Pela sua saúde e pelo planeta!**"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .padding(.bottom, 12)
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 3:
            IntroductionFooterCard {
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 4, 5:
            IntroductionFooterCard(isTransparent: true) {
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 6:
            IntroductionFooterCard(isTransparent: true) {
                IntroductionContinueRow(
                    total: totalScreens,
                    current: screenNumber,
                    continueEnabled: selectedBean != nil,
                    onBack: goBack,
                    onContinue: goNext
                )
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Navigation

    private func goBack() {
        if screenNumber > 1 { screenNumber -= 1 }
    }

    private func goNext() {
        if screenNumber < totalScreens {
            screenNumber += 1
        } else {
            navigate(.introduction2(screen: 1))
        }
    }
}

// MARK: - Bean option card

private struct BeanOptionCard: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.brandOrange : Color(white: 0.9))
                        .frame(width: 70, height: 70)
                    Text("🫘")
                        .font(.system(size: 32))
                }
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? Color.brandOrange : Color(red: 0.4, green: 0.4, blue: 0.4))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.brandOrange : Color(white: 0.8), lineWidth: 2)
            )
        }
    }
}

#Preview {
    Introduction1View(navigate: { _ in })
}
