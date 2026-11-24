// Introduction6View.swift
// 2 screens — mirrors ScreenIntroduction_6.kt
// Screen 1: balloon card "Antes de embarcar..." + icon_c1 (280dp)
// Screen 2: 11-question food frequency questionnaire

import SwiftUI

struct Introduction6View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int

    private let totalScreens = 2

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

                IntroductionFooterCard(isTransparent: true) {
                    IntroductionNavRow(
                        total: totalScreens, current: screenNumber,
                        onBack: goBack, onNext: goNext
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Screen content

    @ViewBuilder
    private var screenContent: some View {
        switch screenNumber {

        case 1:
            // Android: Introduction_6_1 — balloon card + icon_c1 (280dp)
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text(boldText("Antes de embarcar, vamos ver como está sua alimentação? Para isso, responda algumas perguntas rápidas."))
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .lineSpacing(4)

                    Spacer().frame(height: 4)

                    Text("Vamos começar?")
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

                Spacer().frame(height: 20)

                Image("icon_c1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 280)
            }
            .padding(.horizontal, 4)

        case 2:
            // Android: Introduction_6_2 — food frequency questionnaire
            Intro6QuestionnaireView(onConfirm: { navigate(.introduction7(screen: 1)) })

        default:
            EmptyView()
        }
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
            navigate(.introduction7(screen: 1))
        }
    }
}

// MARK: - Questionnaire (screen 2)

private struct Intro6QuestionnaireView: View {
    let onConfirm: () -> Void

    @State private var respostas: [Int: Int] = [:]
    @State private var showDialog = false

    // Android: 7 options (index 1–7)
    private let options = [
        "Nunca",
        "Até 1x/mês",
        "2 a 3x/mês",
        "1 a 2x/semana",
        "3 a 4x/semana",
        "5 a 6x/semana",
        "Todos os dias",
    ]

    // Android: 11 perguntas
    private let perguntas = [
        "Feijões, lentilha e grão de bico",
        "Frutas frescas (ex: banana, maçã, laranja - não marcar se for suco)",
        "Legumes e verduras (ex: alface, brócolis, cenoura)",
        "Refeições prontas ou fast-food (ex.: batata frita congelada, macarrão instantâneo, lasanha congelada, pizza etc.)",
        "Molhos prontos e margarina (ex.: ketchup, maionese, mostarda, molhos prontos para salada etc.)",
        "Pães de pacote (ex.: pão de forma, pão de hambúrguer, de cachorro-quente, bisnaguinha, torrada de pacote etc.)",
        "Embutidos (ex: hambúrguer, salsicha, mortadela, nuggets, empanado, presunto, peito de peru, linguiça etc.)",
        "Bebidas adoçadas (ex: refrigerantes, suco de caixinha, chá gelado em lata ou caixinha etc.)",
        "Iogurtes com sabor, bebidas lácteas e achocolatados",
        "Snacks salgados (ex: salgadinhos de pacote e biscoitos salgados, tipo água e sal)",
        "Doces e guloseimas (ex: sorvete, gelatina, chocolate, bombom, bolo de pacote, barra de cereal, balas etc.)"
    ]

    private var todasRespondidas: Bool { respostas.count == perguntas.count }

    // Android scoring: q0-2 = healthy (score = resposta-1), q8-10 = ultra (score = 7-resposta), max=36
    private func calcularPontuacao() -> Int {
        respostas.reduce(0) { total, entry in
            let (index, resposta) = entry
            switch index {
            case 0...2: return total + (resposta - 1)
            case 8...10: return total + (7 - resposta)
            default: return total
            }
        }
    }

    private func calcularNota(_ pontos: Int) -> Int {
        Int((Float(pontos) * 100.0 / 36.0).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Com que frequência você consome os seguintes alimentos:")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
                .padding(.bottom, 14)

            ForEach(perguntas.indices, id: \.self) { idx in
                Text(perguntas[idx])
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 8)

                VStack(spacing: 6) {
                    ForEach(options.indices, id: \.self) { optIdx in
                        let optIndex = optIdx + 1
                        Intro6OptionButton(
                            label: options[optIdx],
                            isSelected: respostas[idx] == optIndex
                        ) {
                            respostas[idx] = optIndex
                        }
                    }
                }
                .padding(.bottom, 20)
            }

            if todasRespondidas {
                Spacer().frame(height: 8)
                Button {
                    showDialog = true
                } label: {
                    Text("COMO ESTÁ MINHA ALIMENTAÇÃO?")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        // Android primary_100 = #CE7257
                        .background(Color(red: 0.808, green: 0.447, blue: 0.341))
                        .cornerRadius(8)
                }
                Spacer().frame(height: 16)
            }
        }
        .sheet(isPresented: $showDialog) {
            let pontos = calcularPontuacao()
            let nota = calcularNota(pontos)
            Intro6ResultSheet(nota: nota, onContinue: {
                showDialog = false
                onConfirm()
            }, onCancel: {
                showDialog = false
            })
        }
    }
}

// MARK: - Option button (Android selectNoShowOption: white bg, secondary_200 border when selected)

private struct Intro6OptionButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    // Android secondary_200 = #c64b4e
    private let selectedColor = Color(red: 0.776, green: 0.294, blue: 0.306)

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? selectedColor : .black)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? selectedColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Result sheet (mirrors MyDialogPointsBottom)

private struct Intro6ResultSheet: View {
    let nota: Int
    let onContinue: () -> Void
    let onCancel: () -> Void

    // Android primary_100 = #CE7257
    private let orange = Color(red: 0.808, green: 0.447, blue: 0.341)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Capsule()
                    .fill(Color(white: 0.8))
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, 20)

            Text("Você finalizou o questionário")
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

            Spacer().frame(height: 12)

            Text("\(nota)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(orange)

            Text("Pontuação alimentar (0–100)")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))

            Spacer().frame(height: 20)

            Text("Deseja continuar?")
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

            Spacer().frame(height: 24)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancelar")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(white: 0.95))
                        .cornerRadius(8)
                }

                Button(action: onContinue) {
                    Text("CONTINUAR")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(orange)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 32)
        }
        .background(Color.white)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    Introduction6View(navigate: { _ in })
}
