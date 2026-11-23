// HowItWorksView.swift
// Ports ui/screens/iaFood/HowItWorksCard route — explains the AI Food feature

import SwiftUI

struct HowItWorksView: View {

    var dismiss: () -> Void

    private let orange = Color(red: 0.831, green: 0.427, blue: 0.290)

    var body: some View {
        VStack(spacing: 0) {

            // Header
            ZStack {
                Button(action: dismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.leading, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("Como funciona")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(height: 44)
            .padding(.top, 8)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Icon
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(orange.opacity(0.12))
                                .frame(width: 80, height: 80)
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 36))
                                .foregroundColor(orange)
                        }
                        Spacer()
                    }
                    .padding(.top, 24)

                    stepCard(
                        number: "1",
                        title: "Tire uma foto",
                        body: "Fotografe o seu café da manhã, almoço ou jantar."
                    )

                    stepCard(
                        number: "2",
                        title: "Informe a refeição",
                        body: "Diga qual refeição é e se há substituto de carne no prato."
                    )

                    stepCard(
                        number: "3",
                        title: "Receba a análise",
                        body: "Nossa inteligência artificial vai analisar os alimentos e te dar um retorno personalizado com base na proposta do programa."
                    )

                    // Credits info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(orange)
                            Text("Créditos de análise")
                                .font(.system(size: 15, weight: .bold))
                        }

                        Text("Você ganha 10 análises ao iniciar cada módulo do programa. Quando acabar, é possível comprar mais usando seus feijões.")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)

                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func stepCard(number: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(orange)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Text(body)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
