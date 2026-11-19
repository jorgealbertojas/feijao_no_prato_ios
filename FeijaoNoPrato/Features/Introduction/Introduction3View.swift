// Introduction3View.swift
// 2 quiz screens with true/false and multiple choice
// Mirrors ScreenIntroduction_3.kt

import SwiftUI

struct Introduction3View: View {

    let initialScreen: Int
    var navigate: (AppRoute) -> Void

    @State private var screenNumber: Int
    @State private var selectedAnswer: String? = nil
    @State private var showFeedback = false

    private let totalScreens = 2

    init(initialScreen: Int = 1, navigate: @escaping (AppRoute) -> Void) {
        self.initialScreen = initialScreen
        self.navigate = navigate
        _screenNumber = State(initialValue: initialScreen)
    }

    // Quiz data for each screen
    private var quiz: QuizData {
        switch screenNumber {
        case 1:
            return QuizData(
                question: "Contar calorias para manter o peso é a melhor estratégia de alimentação saudável?",
                options: ["Verdadeiro", "Falso"],
                correctAnswer: "Falso",
                correctFeedback: "A melhor estratégia para um peso saudável é bem mais **simples** do que ficar fazendo conta, o mais importante é priorizar a **comida de verdade**.",
                wrongFeedback: "Contar calorias é complicado. Priorizar a comida de verdade é muito mais simples, previne doenças e ainda protege contra o ganho de peso excessivo!"
            )
        case 2:
            return QuizData(
                question: "Qual combinação é a base das refeições saudáveis no dia a dia?",
                options: ["Arroz e feijão", "Salada e frango", "Macarrão com queijo"],
                correctAnswer: "Arroz e feijão",
                correctFeedback: "Sim! Nosso clássico deve ser a base da sua alimentação. Simples, acessível, saboroso, nutritivo, versátil, é tudo de bom.",
                wrongFeedback: "Arroz e feijão formam a combinação mais equilibrada e nutritiva. São simples, acessíveis e deliciosos!"
            )
        default:
            return QuizData(question: "", options: [], correctAnswer: "", correctFeedback: "", wrongFeedback: "")
        }
    }

    var body: some View {
        IntroductionBackground {
            VStack(spacing: 0) {
                ScrollView {
                    quizContent
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                IntroductionFooterCard(isTransparent: true) {
                    IntroductionContinueRow(
                        total: totalScreens,
                        current: screenNumber,
                        continueEnabled: selectedAnswer != nil,
                        onBack: goBack,
                        onContinue: { showFeedback = true }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFeedback) {
            if let answer = selectedAnswer {
                let isCorrect = answer == quiz.correctAnswer
                QuizFeedbackSheet(
                    isCorrect: isCorrect,
                    feedbackText: isCorrect ? quiz.correctFeedback : quiz.wrongFeedback,
                    onContinue: {
                        showFeedback = false
                        goNext()
                    },
                    onCancel: {
                        showFeedback = false
                        selectedAnswer = nil
                    }
                )
            }
        }
    }

    // MARK: - Quiz content

    private var quizContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "questionmark.bubble.fill")
                .resizable().scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.brandOrange)
                .padding(.top, 20)

            Text(quiz.question)
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))

            VStack(spacing: 12) {
                ForEach(quiz.options, id: \.self) { option in
                    QuizOptionButton(
                        label: option,
                        isSelected: selectedAnswer == option
                    ) {
                        selectedAnswer = option
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    private func goBack() {
        selectedAnswer = nil
        if screenNumber > 1 {
            screenNumber -= 1
        } else {
            navigate(.introduction2(screen: 4))
        }
    }

    private func goNext() {
        selectedAnswer = nil
        if screenNumber < totalScreens {
            screenNumber += 1
        } else {
            navigate(.introduction4(screen: 1))
        }
    }
}

// MARK: - Quiz data model

private struct QuizData {
    let question: String
    let options: [String]
    let correctAnswer: String
    let correctFeedback: String
    let wrongFeedback: String
}

#Preview {
    Introduction3View(navigate: { _ in })
}
