// GamificacaoView.swift
// Ports pontos/GamificacaoScreen.kt — points balance and summary screen

import SwiftUI

struct GamificacaoView: View {

    var dismiss: () -> Void

    @EnvironmentObject var gamificacaoViewModel: GamificacaoViewModel

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Header
            ZStack {
                Button(action: dismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.leading, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("Meus Feijões")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(height: 44)
            .padding(.top, 8)

            Divider()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Balance hero card
                    balanceCard

                    // MARK: Breakdown cards
                    HStack(spacing: 12) {
                        statCard(
                            title: "Acumulados",
                            value: gamificacaoViewModel.pontuacao.totalAcumulado,
                            color: .green,
                            icon: "plus.circle.fill"
                        )
                        statCard(
                            title: "Consumidos",
                            value: gamificacaoViewModel.pontuacao.totalConsumido,
                            color: .red,
                            icon: "minus.circle.fill"
                        )
                    }
                    .padding(.horizontal, 16)

                    // MARK: Rescued items
                    if !gamificacaoViewModel.rescuedItems.isEmpty {
                        rescuedSection
                    }

                    // MARK: Info footer
                    Text("Os feijões são ganhos ao completar sessões e atividades do programa. Use-os para resgatar itens na Feira.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
                .padding(.top, 24)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Balance card

    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("🫘")
                .font(.system(size: 48))

            Text("\(gamificacaoViewModel.pontuacao.saldo)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(Color.brandOrange)

            Text("Saldo disponível")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Stat card

    private func statCard(title: String, value: Int, color: Color, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text("\(value)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(.label))
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
    }

    // MARK: - Rescued items

    private var rescuedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Itens resgatados")
                .font(.system(size: 15, weight: .bold))
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(gamificacaoViewModel.rescuedItems, id: \.self) { itemID in
                        VStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            Text("#\(itemID)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 70, height: 70)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
