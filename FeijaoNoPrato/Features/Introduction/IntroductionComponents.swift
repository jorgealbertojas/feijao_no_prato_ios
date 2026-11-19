// IntroductionComponents.swift
// Shared components used across all introduction screens

import SwiftUI

// MARK: - Rounded corners shape (top only)

struct RoundedCornersShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Background wrapper

struct IntroductionBackground<Content: View>: View {
    let isWhite: Bool
    let isCarioquina: Bool
    @ViewBuilder var content: Content

    init(isWhite: Bool = false, isCarioquina: Bool = false, @ViewBuilder content: () -> Content) {
        self.isWhite = isWhite
        self.isCarioquina = isCarioquina
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundColor.ignoresSafeArea()
            content
        }
    }

    private var backgroundColor: Color {
        if isWhite { return .white }
        if isCarioquina { return Color(red: 0.698, green: 0.388, blue: 0.267) }
        return Color(red: 0.149, green: 0.149, blue: 0.165)
    }
}

// MARK: - Footer card

struct IntroductionFooterCard<Content: View>: View {
    let isTransparent: Bool
    @ViewBuilder var content: Content

    init(isTransparent: Bool = false, @ViewBuilder content: () -> Content) {
        self.isTransparent = isTransparent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(isTransparent ? Color.clear : Color.white)
        .clipShape(RoundedCornersShape(radius: 32, corners: [.topLeft, .topRight]))
    }
}

// MARK: - Navigation row (back arrow, dots, forward arrow)

struct IntroductionNavRow: View {
    let total: Int
    let current: Int
    let showArrows: Bool
    let hideArrowsBorderless: Bool
    var onBack: () -> Void
    var onNext: () -> Void

    init(
        total: Int,
        current: Int,
        showArrows: Bool = true,
        hideArrowsBorderless: Bool = false,
        onBack: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.total = total
        self.current = current
        self.showArrows = showArrows
        self.hideArrowsBorderless = hideArrowsBorderless
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        HStack {
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .strokeBorder(showArrows ? Color.brandOrange : Color.clear, lineWidth: 2)
                        .frame(width: 56, height: 56)
                    if showArrows {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.brandOrange)
                    }
                }
            }

            Spacer()

            HStack(spacing: 14) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i == current - 1 ? Color(red: 0.545, green: 0.243, blue: 0.184) : Color(red: 0.792, green: 0.431, blue: 0.298))
                        .frame(width: 10, height: 10)
                }
            }

            Spacer()

            Button(action: onNext) {
                ZStack {
                    Circle()
                        .fill(showArrows ? Color.brandOrange : Color.clear)
                        .frame(width: 56, height: 56)
                    if showArrows {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Continue button row

struct IntroductionContinueRow: View {
    let total: Int
    let current: Int
    let continueEnabled: Bool
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.brandOrange, lineWidth: 2)
                        .frame(width: 56, height: 56)
                    Image(systemName: "arrow.left")
                        .foregroundColor(.brandOrange)
                }
            }

            Spacer()

            HStack(spacing: 14) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i == current - 1 ? Color(red: 0.545, green: 0.243, blue: 0.184) : Color(red: 0.792, green: 0.431, blue: 0.298))
                        .frame(width: 10, height: 10)
                }
            }

            Spacer()

            Button(action: onContinue) {
                Text("CONTINUAR")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(continueEnabled ? Color.brandOrange : Color(white: 0.8))
                    .clipShape(Capsule())
            }
            .disabled(!continueEnabled)
        }
    }
}

// MARK: - Bold markdown text helper

func boldText(_ text: String) -> AttributedString {
    let cleaned = text
        .replacingOccurrences(of: "\\n", with: "\n")
    return (try? AttributedString(
        markdown: cleaned,
        options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
    )) ?? AttributedString(cleaned)
}

// MARK: - Balloon card

struct BalloonCard: View {
    let text: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(iconColor)
            }

            Text(boldText(text))
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                .lineSpacing(6)
        }
        .padding(24)
    }
}

// MARK: - Quiz option button

struct QuizOptionButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.231, green: 0.231, blue: 0.231))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSelected ? Color.brandOrange : Color(white: 0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.brandOrange : Color(white: 0.8), lineWidth: 1)
                )
                .cornerRadius(12)
        }
    }
}

// MARK: - Quiz feedback sheet

struct QuizFeedbackSheet: View {
    let isCorrect: Bool
    let feedbackText: String
    let onContinue: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color(white: 0.8))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                    .foregroundColor(isCorrect ? .green : Color.brandOrange)
                    .font(.system(size: 24))
                Text("Você selecionou uma alternativa")
                    .font(.system(size: 16, weight: .semibold))
            }

            Text(boldText(feedbackText))
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.231, green: 0.231, blue: 0.231))
                .padding(.horizontal, 8)

            HStack(spacing: 12) {
                Button("Cancelar", action: onCancel)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.95))
                    .cornerRadius(12)

                Button("CONTINUAR", action: onContinue)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.brandOrange)
                    .cornerRadius(12)
            }
            .font(.system(size: 15, weight: .semibold))

            Spacer()
        }
        .padding(.horizontal, 20)
        .presentationDetents([.medium])
    }
}
