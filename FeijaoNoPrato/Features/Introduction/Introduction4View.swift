// Introduction4View.swift
// 2 screens: balloon → carousel with journey modules
// Mirrors ScreenIntroduction_4.kt

import SwiftUI

struct Introduction4View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 2

    private let moduleItems = [
        ("🌱", "Alimentação Real", "Aprenda o que é comida de verdade e por que ela faz diferença"),
        ("🫘", "O Poder do Feijão", "Descubra todos os benefícios do feijão para sua saúde"),
        ("💧", "Hidratação", "Entenda a importância da água no dia a dia"),
        ("🛒", "Feira Livre", "Como montar uma alimentação saudável e econômica"),
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
                Image(systemName: "figure.2.and.child.holdinghands")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.brandOrange)
                    .padding(.top, 40)
                Text(boldText("**Você não estará sozinho nesta jornada!**\n\nA Carioquinha e toda a comunidade do Feijão no Prato vão te apoiar em cada etapa."))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineSpacing(6)
            }

        case 2:
            VStack(spacing: 20) {
                Text(boldText("Ao longo dos **120 dias**, você vai percorrer módulos temáticos:"))
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

                VStack(spacing: 12) {
                    ForEach(moduleItems, id: \.1) { item in
                        ModuleCard(emoji: item.0, title: item.1, description: item.2)
                    }
                }
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
                Spacer().frame(height: 8)
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

// MARK: - Module card

private struct ModuleCard: View {
    let emoji: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 56, height: 56)
                .background(Color.brandOrange.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

#Preview {
    Introduction4View(navigate: { _ in })
}
