// HistoryMenuView.swift
// Ports ui/screens/iaFood/HistoryMenuScreen.kt

import SwiftUI

// MARK: - Trailing-only rounded corners shape

private struct TrailingRoundedShape: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        p.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false
        )
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        p.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
            radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false
        )
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - History drawer overlay

struct HistoryMenuView: View {

    @Binding var isPresented: Bool
    let historyItems: [HistoricoImagemIA]

    @State private var searchText = ""

    // Android: #8E7C54
    private let gold = Color(red: 0.557, green: 0.486, blue: 0.329)

    private var filteredItems: [HistoricoImagemIA] {
        guard !searchText.isEmpty else { return historyItems }
        let q = searchText.lowercased()
        return historyItems.filter {
            $0.refeicao.lowercased().contains(q) || $0.resposta.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {

            // Dimmed backdrop — tap to dismiss
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }

            // Drawer panel (56pt left margin, trailing corners rounded 12pt)
            HStack(spacing: 0) {
                Color.clear.frame(width: 56)

                VStack(alignment: .leading, spacing: 0) {

                    // Header (top padding clears status bar)
                    HStack(spacing: 12) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 22))
                            .foregroundColor(gold)
                        Text("Meu Histórico")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 56)
                    .padding(.bottom, 12)

                    // Search field
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Buscar...", text: $searchText)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)

                    Divider()

                    // List or empty state
                    if filteredItems.isEmpty {
                        Text("Nenhuma análise encontrada.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(16)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(filteredItems) { item in
                                    HistoryRowView(item: item)
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.92))
                .clipShape(TrailingRoundedShape(radius: 12))
            }
            .ignoresSafeArea(edges: .vertical)
        }
        .transition(.move(edge: .leading))
    }
}

// MARK: - Single history row

private struct HistoryRowView: View {

    let item: HistoricoImagemIA

    // Android: icon_gold = #B49F6D
    private let iconGold = Color(red: 0.706, green: 0.624, blue: 0.427)

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 22))
                .foregroundColor(iconGold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.refeicao)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                Text(item.formattedData)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
