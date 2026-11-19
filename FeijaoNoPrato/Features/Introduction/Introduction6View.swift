// Introduction6View.swift
// 2 screens: gamification system introduction + interactive question
// Mirrors ScreenIntroduction_6.kt
// Background: carioquinha_introdution (warm bean brown)

import SwiftUI

struct Introduction6View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int
    @State private var selectedAnswer: String? = nil

    private let totalScreens = 2

    private let gamificationItems = [
        ("circle.hexagongrid.fill", "Feijões", "Ganhe ao completar atividades diárias"),
        ("shield.fill", "Proteções", "Use seus feijões para proteger sua sequência"),
        ("star.fill", "Conquistas", "Alcance marcos especiais na sua jornada"),
    ]

    init(initialScreen: Int = 1, navigate: @escaping (AppRoute) -> Void) {
        self.initialScreen = initialScreen
        self.navigate = navigate
        _screenNumber = State(initialValue: initialScreen)
    }

    var body: some View {
        IntroductionBackground(isCarioquina: true) {
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
                Image(systemName: "circle.hexagongrid.fill")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Text("Sistema de Gamificação")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    ForEach(gamificationItems, id: \.1) { item in
                        GamificationCard(icon: item.0, title: item.1, description: item.2)
                    }
                }
            }

        case 2:
            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .resizable().scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Text("Pronto para ganhar seus primeiros feijões?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Responda corretamente e ganhe seus primeiros **10 feijões**!")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                Text("Qual é o alimento símbolo desta jornada?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    ForEach(["Feijão", "Arroz", "Milho"], id: \.self) { option in
                        Button {
                            selectedAnswer = option
                        } label: {
                            Text(option)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedAnswer == option ? Color(red: 0.698, green: 0.388, blue: 0.267) : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(selectedAnswer == option ? Color.white : Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                }
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Footer

    private var footerCard: some View {
        IntroductionFooterCard(isTransparent: true) {
            if screenNumber == 2 && selectedAnswer != nil {
                Button {
                    navigate(.introduction7(screen: 1))
                } label: {
                    Text("CONTINUAR")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.698, green: 0.388, blue: 0.267))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                Spacer().frame(height: 12)
            }

            IntroductionNavRow(
                total: totalScreens,
                current: screenNumber,
                onBack: goBack,
                onNext: goNext
            )
        }
    }

    // MARK: - Navigation

    private func goBack() {
        selectedAnswer = nil
        if screenNumber > 1 {
            screenNumber -= 1
        } else {
            navigate(.introduction4(screen: 2))
        }
    }

    private func goNext() {
        selectedAnswer = nil
        if screenNumber < totalScreens {
            screenNumber += 1
        } else {
            navigate(.introduction7(screen: 1))
        }
    }
}

// MARK: - Gamification card

private struct GamificationCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .resizable().scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(Color(red: 0.698, green: 0.388, blue: 0.267))
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    Introduction6View(navigate: { _ in })
}
