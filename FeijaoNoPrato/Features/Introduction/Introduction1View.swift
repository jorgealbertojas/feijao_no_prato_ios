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
            // Android: Introduction_1_3 shows R.drawable.dias_t2intro (305×250dp)
            // text goes into the footer card
            VStack {
                Spacer().frame(height: 5)
                Image("dias_t2intro")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 305, height: 250)
            }

        case 4:
            // Android: Introduction_1_4 — balloon card + icon_c3 character (300dp)
            VStack(spacing: 0) {
                // Balloon card with triangle pointer at bottom
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                            .overlay(
                                VStack(spacing: 6) {
                                    Text("Oi, prazer,\neu sou o Feijuca!")
                                        .font(.system(size: 28, weight: .bold))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                        .lineSpacing(4)
                                    Text("É sempre bom ter uma\ncompanhia na trilha.")
                                        .font(.system(size: 18))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                        .lineSpacing(4)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 32)
                            )
                        // Triangle pointer pointing down
                        TriangleDown()
                            .fill(Color.white)
                            .frame(width: 32, height: 16)
                    }
                }

                Spacer().frame(height: 16)

                Image("icon_c3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
            }
            .padding(.horizontal, 4)

        case 5:
            // Android: Introduction_1_55 — same balloon card layout as case 4, different text
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                            .overlay(
                                VStack(spacing: 10) {
                                    Text("Provavelmente eu já te acompanho muitos dias à mesa. Pode ser preto, branco, marrom, vermelho…")
                                        .font(.system(size: 18))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                        .lineSpacing(4)
                                    Text("O que importa é\nFeijão no Prato!")
                                        .font(.system(size: 24, weight: .bold))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                        .lineSpacing(4)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 32)
                            )
                        TriangleDown()
                            .fill(Color.white)
                            .frame(width: 32, height: 16)
                    }
                }

                Spacer().frame(height: 16)

                Image("icon_c3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
            }
            .padding(.horizontal, 4)

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
            // Android footer: bold title + subtitle + nav row
            IntroductionFooterCard {
                Text(boldText("**Mudar de hábitos não é fácil, mas vamos te ajudar.**"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(6)
                    .padding(.bottom, 12)
                Text(boldText("Será uma jornada de **120 dias que irão transformar sua alimentação.** Sem contar calorias, sem dietas da moda e sem metas impossíveis.\n\n**E você terá um amigo nesta viagem...**"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(6)
                    .padding(.bottom, 12)
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
