// Introduction5View.swift
// 7-screen app tour with full-screen images + footer text
// Mirrors ScreenIntroduction_5.kt

import SwiftUI

struct Introduction5View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 7

    // Android: imageList matches screenNumber 1–7
    private let images = [
        "icon_intro_home",
        "icon_intro_bean",
        "icon_intro_water",
        "icon_intro_progress",
        "icon_intro_feira",
        "icon_intro_conta",
        "icon_intro_ia",
    ]

    // Android: title text per screen (Util.getBoldAnnotatedString)
    private var titleText: String {
        switch screenNumber {
        case 1:
            return "Aqui, no botão de início, está o **percurso** que vamos trilhar juntos: cada seção é pensada para transformar seu dia a dia progressivamente, com aprendizados **leves e aplicáveis**!"
        case 2:
            return "Aqui no topo, você encontra seus **feijões** que você vai ganhar ao completar atividades. Eles podem ser trocados por materiais e proteções."
        case 3:
            return "E também a hidratação esse é o seu termômetro de constância. Faça as atividades do dia para manter o feijuca saudável! Se pular dias, ele pode murchar... mas não se preocupe, dá pra recuperar também!"
        case 4:
            return "No menu inferior, você também pode sempre checar onde está na jornada, na aba **de progresso**. São **120 dias**!"
        case 5:
            return "No menu inferior você encontra a **feira**, esta aba vai te ajudar a **aprofundar** seu conhecimento e tornar a alimentação saudável parte natural do seu dia a dia."
        case 6:
            return "A última aba do menu inferior é a conta, seus **dados cadastrais** ficam aqui."
        case 7:
            return "Neste ícone está a IA no prato, ao enviar a foto da sua refeição, nossa inteligência artificial entra em ação para te oferecer uma análise personalizada, com base no Guia Alimentar para a População Brasileira!"
        default:
            return ""
        }
    }

    private var currentImage: String {
        guard screenNumber >= 1, screenNumber <= images.count else { return "" }
        return images[screenNumber - 1]
    }

    init(initialScreen: Int = 1, navigate: @escaping (AppRoute) -> Void) {
        self.initialScreen = initialScreen
        self.navigate = navigate
        _screenNumber = State(initialValue: initialScreen)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Android: Image fills entire screen (ContentScale.FillBounds)
            Image(currentImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            // Footer card overlaid at bottom
            IntroductionFooterCard {
                Text(boldText(titleText))
                    .font(.system(size: 18))
                    .lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

                Spacer().frame(height: 16)

                IntroductionNavRow(
                    total: totalScreens, current: screenNumber,
                    onBack: goBack, onNext: goNext
                )
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
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
