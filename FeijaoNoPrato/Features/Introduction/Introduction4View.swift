// Introduction4View.swift
// 2 screens — mirrors ScreenIntroduction_4.kt
// Screen 1: balloon card "E assim caminharemos..." + icon_f2
// Screen 2: icon_logo (introduction_app) + carousel with 5 journey features

import SwiftUI

struct Introduction4View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 2

    // Android Introduction_carousel4 items + icon names
    private let carouselItems: [(text: String, icon: String)] = [
        ("Percurso dividido em seções **curtas**, uma a cada dia.", "icon_street"),
        ("Quizzes e desafios para tornar o aprendizado leve e divertido.", "icon_quizz"),
        ("Atividade interativa de avaliação da **qualidade** do seu prato.", "icon_food_new"),
        ("**Recompensa** em feijões virtuais para te manter engajado nas atividades.", "icon_currency"),
        ("**Barra de progresso** para monitorar seu avanço e muito mais!", "icon_progress"),
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
            // Android: Introduction_4_0 — balloon card + icon_f2 (250dp)
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text(boldText("E assim caminharemos! Seremos simples e acessíveis, navegando sempre em um terreno que o Brasil conhece bem: o da comida de verdade."))
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .lineSpacing(4)

                    Spacer().frame(height: 10)

                    Text("E a jornada foi feita para ser leve!")
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

                Image("icon_f2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
            .padding(.horizontal, 4)

        case 2:
            // Android: Introduction_4_3 — logo image (200dp)
            VStack {
                Spacer().frame(height: 40)
                Image("icon_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer().frame(height: 20)
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
                IntroductionNavRow(
                    total: totalScreens, current: screenNumber,
                    onBack: goBack, onNext: goNext
                )
            }

        case 2:
            // Android: carousel + nav row (inside the footer card)
            IntroductionFooterCard {
                Spacer().frame(height: 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(carouselItems, id: \.icon) { item in
                            Intro4CarouselCard(text: item.text, iconName: item.icon)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
                Spacer().frame(height: 16)
                IntroductionNavRow(
                    total: totalScreens, current: screenNumber,
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
            navigate(.introduction3(screen: 2))
        }
    }

    private func goNext() {
        if screenNumber < totalScreens {
            screenNumber += 1
        } else {
            navigate(.introduction6(screen: 1))
        }
    }
}

// MARK: - Carousel card (Android CarouselCard: icon 50dp + text 14sp, 200×200, carioquina_10 @10%)

private struct Intro4CarouselCard: View {
    let text: String
    let iconName: String

    // Android carioquina_10 #CE7257 at 0.1 alpha
    private let cardBg = Color(red: 0.808, green: 0.447, blue: 0.341).opacity(0.1)

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text(boldText(text))
                .font(.system(size: 14))
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
    Introduction4View(navigate: { _ in })
}
