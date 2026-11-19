// Introduction2View.swift
// 4 screens: bean intro → "feijão é simples" → carousel → final
// Mirrors ScreenIntroduction_2.kt

import SwiftUI

struct Introduction2View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 4

    private let carouselItems = [
        ("fork.knife", "Alimentação real", "Comida de verdade, sem ultra-processados"),
        ("figure.walk", "Hábitos saudáveis", "Pequenas mudanças que se tornam rotina"),
        ("leaf.fill", "Sustentabilidade", "Bem para você e para o planeta"),
        ("star.fill", "Jornada de 120 dias", "Transformação progressiva e duradoura"),
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
            VStack(spacing: 20) {
                Image(systemName: "circle.hexagongrid.fill")
                    .resizable().scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color.brandOrange)
                    .padding(.top, 40)
                Text(boldText("**O feijão** é o alimento mais consumido pelos brasileiros e é a base de uma alimentação saudável."))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineSpacing(6)
            }

        case 2:
            BalloonCard(
                text: "Além disso, feijão é simples.\n\nE o simples combina com alimentação saudável! Comida de verdade, saborosa, que protege contra doenças. \n\nDe quebra, faz bem também para o planeta.",
                icon: "checkmark.seal.fill",
                iconColor: Color.brandOrange
            )

        case 3:
            VStack(spacing: 20) {
                Text(boldText("Nosso app vai passar por pontos fundamentais para transformar sua relação com a comida:"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(carouselItems, id: \.0) { item in
                            CarouselCard(icon: item.0, title: item.1, description: item.2)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

        case 4:
            VStack(spacing: 20) {
                Image(systemName: "tortoise.fill")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.brandOrange)
                    .padding(.top, 40)
                Text(boldText("Vamos começar sua jornada?\n\n**Passo a passo, dia a dia**, você vai transformar sua alimentação de forma sustentável!"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
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
        case 1, 4:
            IntroductionFooterCard(isTransparent: true) {
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 2:
            IntroductionFooterCard {
                Text("Além disso, feijão é simples.")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                Spacer().frame(height: 10)
                IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
            }

        case 3:
            IntroductionFooterCard {
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

// MARK: - Carousel card

private struct CarouselCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .resizable().scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color.brandOrange)

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

            Text(description)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .padding(16)
        .frame(width: 160)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
    }
}

#Preview {
    Introduction2View(navigate: { _ in })
}
