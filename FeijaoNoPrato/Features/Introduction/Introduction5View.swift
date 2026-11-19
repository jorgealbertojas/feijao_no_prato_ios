// Introduction5View.swift
// 7 screens: app tour showing each section with image + description
// Mirrors ScreenIntroduction_5.kt

import SwiftUI

struct Introduction5View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 7

    init(initialScreen: Int = 1, navigate: @escaping (AppRoute) -> Void) {
        self.initialScreen = initialScreen
        self.navigate = navigate
        _screenNumber = State(initialValue: initialScreen)
    }

    private var tourData: (icon: String, title: String, text: String) {
        switch screenNumber {
        case 1:
            return ("house.fill", "Início",
                "Aqui, no botão de início, está o **percurso** que vamos trilhar juntos: cada seção é pensada para transformar seu dia a dia progressivamente, com aprendizados **leves e aplicáveis**!")
        case 2:
            return ("circle.hexagongrid.fill", "Seus Feijões",
                "Aqui no topo, você encontra seus **feijões** que você vai ganhar ao completar atividades. Eles podem ser trocados por materiais e proteções.")
        case 3:
            return ("drop.fill", "Hidratação",
                "E também a hidratação — esse é o seu termômetro de constância. Faça as atividades do dia para manter o feijuca saudável! Se pular dias, ele pode murchar... mas não se preocupe, dá pra recuperar também!")
        case 4:
            return ("chart.bar.fill", "Progresso",
                "No menu inferior, você também pode sempre checar onde está na jornada, na aba **de progresso**. São **120 dias**!")
        case 5:
            return ("cart.fill", "Feira",
                "No menu inferior você encontra a **feira**, esta aba vai te ajudar a **aprofundar** seu conhecimento e tornar a alimentação saudável parte natural do seu dia a dia.")
        case 6:
            return ("person.fill", "Conta",
                "A última aba do menu inferior é a conta, seus **dados cadastrais** ficam aqui.")
        case 7:
            return ("camera.fill", "IA no Prato",
                "Neste ícone está a IA no prato, ao enviar a foto da sua refeição, nossa inteligência artificial entra em ação para te oferecer uma análise personalizada, com base no Guia Alimentar para a População Brasileira!")
        default:
            return ("questionmark", "", "")
        }
    }

    var body: some View {
        IntroductionBackground {
            VStack(spacing: 0) {
                // Full-screen illustration area
                ZStack {
                    Color.brandOrange.opacity(0.12)
                        .ignoresSafeArea(edges: .top)

                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: tourData.icon)
                            .resizable().scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color.brandOrange)
                        Text(tourData.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, minHeight: 280)

                IntroductionFooterCard {
                    Text(boldText(tourData.text))
                        .font(.system(size: 18))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

                    Spacer().frame(height: 16)

                    IntroductionNavRow(total: totalScreens, current: screenNumber, onBack: goBack, onNext: goNext)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Navigation

    private func goBack() {
        if screenNumber > 1 {
            screenNumber -= 1
        } else {
            navigate(.introduction4(screen: 2))
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

#Preview {
    Introduction5View(navigate: { _ in })
}
