// HistoricoFeijoesView.swift
// Ports pontos/GamificacaoScreen.kt historico section

import SwiftUI

struct HistoricoFeijoesView: View {

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

                Text("Histórico de Feijões")
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(height: 44)
            .padding(.top, 8)

            Divider()

            // MARK: Balance strip
            HStack(spacing: 16) {
                balanceChip(label: "Acumulados", value: gamificacaoViewModel.pontuacao.totalAcumulado, color: .green)
                balanceChip(label: "Consumidos",  value: gamificacaoViewModel.pontuacao.totalConsumido,  color: .red)
                balanceChip(label: "Saldo",       value: gamificacaoViewModel.pontuacao.saldo,           color: .brandOrange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGroupedBackground))

            // MARK: List
            if gamificacaoViewModel.pontuacao.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if gamificacaoViewModel.historico.isEmpty {
                emptyState
            } else {
                List(gamificacaoViewModel.historico) { item in
                    PontoAtividadeRow(item: item)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparatorTint(Color(white: 0.9))
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Balance chip

    private func balanceChip(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "leaf.circle")
                .font(.system(size: 52))
                .foregroundColor(Color(white: 0.8))
            Text("Nenhum feijão registrado ainda.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

// MARK: - PontoAtividadeRow

private struct PontoAtividadeRow: View {

    let item: PontoAtividade

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.atividade.isEmpty ? "Atividade" : item.atividade)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Spacer()

                HStack(spacing: 3) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                    Text("+\(item.pontos)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
            }

            if !item.modulo_numero.isEmpty {
                Text("Módulo \(item.modulo_numero)\(item.modulo != "0" && !item.modulo.isEmpty ? " — \(item.modulo)" : "")")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            if !item.data.isEmpty {
                Text(item.data.formattedHistoricoDate())
                    .font(.system(size: 11))
                    .foregroundColor(Color(white: 0.6))
            }
        }
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
    }
}

// MARK: - Date formatting

private extension String {
    func formattedHistoricoDate() -> String {
        // Try ISO-8601 first, fall back to raw string
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: self) {
            return DateFormatter.historicoFormatter.string(from: date)
        }
        let iso2 = ISO8601DateFormatter()
        if let date = iso2.date(from: self) {
            return DateFormatter.historicoFormatter.string(from: date)
        }
        return self
    }
}

private extension DateFormatter {
    static let historicoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yy 'às' HH:mm"
        return f
    }()
}

#Preview {
    HistoricoFeijoesView(dismiss: {})
        .environmentObject({
            let vm = GamificacaoViewModel()
            return vm
        }())
}
