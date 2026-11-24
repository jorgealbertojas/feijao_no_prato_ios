// Introduction2View.swift
// 4 screens — mirrors ScreenIntroduction_2.kt

import SwiftUI

struct Introduction2View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 4

    // Android carousel items (Introduction_carousel_2)
    private let carouselItems = [
        "Como escolher alimentos saudáveis",
        "Como combinar alimentos",
        "Como organizar a rotina, a geladeira e a despensa",
        "Como lidar com os obstáculos do dia-a-dia",
        "O básico das habilidades para se virar na cozinha",
        "E, claro, receitas!",
    ]

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
            // Android: Introduction_1_6 — speech balloon card + icon_c2 (250dp)
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text("Não é incrível como um alimento tão simples é saudável e é a cara do Brasil?")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .lineSpacing(4)
                    Text("Não importa o tipo, o feijão é muito saudável e central na alimentação no Brasil. Por isso ele foi escolhido para te acompanhar!")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
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

                Spacer().frame(height: 30)

                Image("icon_c2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            .padding(.horizontal, 4)

        case 2:
            // Android: Introduction_2_1 — icon_c1 (305×250dp)
            VStack {
                Spacer().frame(height: 50)
                Image("icon_c1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 305, height: 250)
            }

        case 3:
            // Android: Introduction_2_4 — icon_f2 (240dp)
            VStack {
                Image("icon_f2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
            }

        case 4:
            // Android: Introduction_2_6 — speech balloon card + icon_c2 (300dp)
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text("E não vou ser só eu falando, não!")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .lineSpacing(4)
                    Text("Nossa jornada vai ter muita interação! Perguntas para fixar o aprendizado e acompanhar sua evolução. Quer ver um exemplo?")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
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

                Spacer().frame(height: 20)

                Image("icon_c2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
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

        case 1, 4:
            IntroductionFooterCard(isTransparent: true) {
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 2:
            // Android: title + subTitle + nav row
            IntroductionFooterCard {
                Text("Além disso, feijão é simples.")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                Spacer().frame(height: 10)
                Text("E o simples combina com alimentação saudável! Comida de verdade, saborosa, que protege contra doenças. \n De quebra, faz bem também para o planeta.")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(4)
                    .padding(.bottom, 8)
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 3:
            // Android: subTitle + carousel + nav row
            IntroductionFooterCard {
                Text("Nosso app vai passar por pontos fundamentais para transformar sua relação com a comida:")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                    .lineSpacing(4)
                    .padding(.bottom, 6)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(carouselItems, id: \.self) { item in
                            Intro2CarouselCard(text: item)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }

                Spacer().frame(height: 16)
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
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
            navigate(.introduction1(screen: 6))
        }
    }

    private func goNext() {
        if screenNumber < totalScreens {
            screenNumber += 1
        } else {
            navigate(.introduction3(screen: 1))
        }
    }
}

// MARK: - Carousel card (Android carioquina_10 @10% alpha background)

private struct Intro2CarouselCard: View {
    let text: String

    // Android carioquina_10 #CE7257 at 0.1 alpha
    private let cardBg = Color(red: 0.808, green: 0.447, blue: 0.341).opacity(0.1)

    var body: some View {
        let parts = text.components(separatedBy: " ")
        let last = parts.last ?? ""
        let rest = parts.dropLast().joined(separator: " ")

        VStack(alignment: .center, spacing: 0) {
            Text(rest)
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            Text(last)
                .font(.system(size: 18, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
        .padding(16)
        .frame(width: 200, height: 200)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

#Preview {
    Introduction2View(navigate: { _ in })
}
