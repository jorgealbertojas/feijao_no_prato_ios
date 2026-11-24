// Introduction1View.swift
// 6 screens: welcome → nutrition → 120-day journey → balloon x2 → bean selection
// Mirrors ScreenIntroduction_1.kt

import SwiftUI

struct Introduction1View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int
    @State private var selectedBean: String? = "Vermelho"

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
            // Android: Introduction_1_selectedBean — vertical list, each row has image + name
            VStack(alignment: .leading, spacing: 6) {
                Text("Qual desses aparece mais no seu dia a dia?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .padding(.bottom, 6)

                ForEach(BeanData.all, id: \.name) { bean in
                    BeanRowItem(bean: bean, isSelected: selectedBean == bean.name) {
                        selectedBean = bean.name
                    }
                }
            }
            .padding(24)

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

// MARK: - Bean data model

struct BeanData {
    let name: String
    let color: Color
    let imageName: String

    static let all: [BeanData] = [
        BeanData(name: "Preto",              color: Color(red: 0.169, green: 0.110, blue: 0.094), imageName: "beans_black"),
        BeanData(name: "Carioca",            color: Color(red: 0.784, green: 0.635, blue: 0.482), imageName: "beans_carioca"),
        BeanData(name: "Branco",             color: Color(red: 0.949, green: 0.851, blue: 0.780), imageName: "beans_white"),
        BeanData(name: "Vermelho",           color: Color(red: 0.608, green: 0.169, blue: 0.169), imageName: "beans_red"),
        BeanData(name: "Verde",              color: Color(red: 0.537, green: 0.608, blue: 0.129), imageName: "beans_green"),
        BeanData(name: "Fradinho ou de-corda", color: Color(red: 0.976, green: 0.886, blue: 0.263), imageName: "beans_fradinho"),
        BeanData(name: "Roxo",              color: Color(red: 0.667, green: 0.325, blue: 1.0),    imageName: "beans_purple"),
        BeanData(name: "Rajado",             color: Color(red: 0.631, green: 0.353, blue: 0.271), imageName: "beans_rajado"),
    ]
}

// MARK: - Bean row item (Android-style: image + name, full-width row)

private struct BeanRowItem: View {
    let bean: BeanData
    let isSelected: Bool
    let action: () -> Void

    // Android quaternary_11 = #F8F7F3
    private let rowBg = Color(red: 0.973, green: 0.969, blue: 0.953)
    // Android selected border = #DE9990
    private let selectedBorder = Color(red: 0.871, green: 0.600, blue: 0.565)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(bean.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                Text(bean.name)
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? bean.color : Color(red: 0.2, green: 0.2, blue: 0.2))

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(rowBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? selectedBorder : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    Introduction1View(navigate: { _ in })
}
