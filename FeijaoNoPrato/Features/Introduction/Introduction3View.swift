// Introduction3View.swift
// 2 quiz screens — mirrors ScreenIntroduction_3.kt
// Screen 1: "Verdadeiro ou falso?" — Contar calorias
// Screen 2: "Escolha a alternativa correta:" — combinação saudável

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

    // Per-screen quiz data (matches Android Introduction_3_text.kt)
    private var quiz: Intro3QuizData {
        switch screenNumber {
        case 1:
            return Intro3QuizData(
                label: "Verdadeiro ou falso?",
                question: "Contar calorias é a forma mais eficaz para perder peso.",
                options: ["Verdadeiro", "Falso"],
                correctAnswer: "Falso",
                feedbackFor: { answer in
                    if answer == "Falso" {
                        return "A melhor estratégia para um peso saudável é bem mais **simples** do que ficar fazendo conta, o mais importante é priorizar a **comida de verdade**."
                    } else {
                        return "Contar calorias é complicado. Priorizar a comida de verdade é muito mais simples, previne doenças e ainda protege contra o ganho de peso excessivo!"
                    }
                }
            )
        case 2:
            return Intro3QuizData(
                label: "Escolha a alternativa correta:",
                question: "A combinação saudável mais presente nos pratos dos brasileiros é:",
                options: ["Salada e frango", "Arroz e feijão", "Arroz integral e peixe"],
                correctAnswer: "Arroz e feijão",
                feedbackFor: { answer in
                    if answer == "Arroz e feijão" {
                        return "Sim! Nosso clássico deve ser a base da sua alimentação. Simples, acessível, saboroso, nutritivo, versátil, é tudo de bom."
                    } else if answer == "Salada e frango" {
                        return "Salada e frango são também muito consumidos, mas a combinação de arroz e feijão é a que forma a base de refeições saudáveis no dia-a-dia."
                    } else {
                        return "É uma combinação saudável, mas não tão comum quanto o nosso clássico arroz com feijão, que é tão amado por ser mais versátil, simples, além de ser uma delícia!"
                    }
                }
            )
        default:
            return Intro3QuizData(label: "", question: "", options: [], correctAnswer: "", feedbackFor: { _ in "" })
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
                        onContinue: {
                            if selectedAnswer != nil { showFeedback = true }
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFeedback) {
            if let answer = selectedAnswer {
                let isCorrect = answer == quiz.correctAnswer
                Intro3FeedbackSheet(
                    isCorrect: isCorrect,
                    feedbackText: quiz.feedbackFor(answer),
                    onContinue: {
                        showFeedback = false
                        goNext()
                    },
                    onDismiss: {
                        showFeedback = false
                        selectedAnswer = nil
                    }
                )
            }
        }
        .onChange(of: screenNumber) { _ in
            selectedAnswer = nil
        }
    }

    // MARK: - Quiz content

    private var quizContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(quiz.label)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)

            Text(boldText(quiz.question))
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .lineSpacing(4)

            VStack(spacing: 8) {
                ForEach(quiz.options, id: \.self) { option in
                    Intro3OptionButton(
                        label: option,
                        isSelected: selectedAnswer == option
                    ) {
                        selectedAnswer = option
                    }
                }
            }
        }
        .padding(.top, 8)
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

private struct Intro3QuizData {
    let label: String
    let question: String
    let options: [String]
    let correctAnswer: String
    let feedbackFor: (String) -> String
}

// MARK: - Option button (Android: white bg, secondary_200 #c64b4e border+text when selected)

private struct Intro3OptionButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    // Android secondary_200 = #c64b4e
    private let selectedColor = Color(red: 0.776, green: 0.294, blue: 0.306)

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? selectedColor : .black)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? selectedColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Feedback bottom sheet (mirrors MyDialogIntroductionBottom)

private struct Intro3FeedbackSheet: View {
    let isCorrect: Bool
    let feedbackText: String
    let onContinue: () -> Void
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    // Android green_200 = #1fc16b
    private let greenCorrect = Color(red: 0.122, green: 0.757, blue: 0.420)
    // Android primary_100 = #CE7257
    private let orangeWrong = Color(red: 0.808, green: 0.447, blue: 0.341)

    private var accentColor: Color { isCorrect ? greenCorrect : orangeWrong }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Capsule()
                    .fill(Color(white: 0.8))
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, 20)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(isCorrect ? "CORRETO" : "INCORRETO")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(accentColor)

                    Text(isCorrect ? "Parabéns! Acertou em cheio." : "Ops! Não é essa a resposta.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))

                    Spacer().frame(height: 8)

                    Text(boldText(feedbackText))
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 26)

            Button(action: onContinue) {
                Text("CONTINUAR")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(accentColor)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.white)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onDisappear { onDismiss() }
    }
}

#Preview {
    Introduction3View(navigate: { _ in })
}
