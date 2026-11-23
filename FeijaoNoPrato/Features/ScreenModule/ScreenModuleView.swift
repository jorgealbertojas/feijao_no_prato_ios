// ScreenModuleView.swift
// Replaces ui/screens/screenModule/ScreenModule.kt + MyCardItemViewSession.kt

import SwiftUI

struct ScreenModuleView: View {

    var navigate: (AppRoute) -> Void
    var dismiss: () -> Void

    @StateObject private var viewModel = ScreenModuleViewModel()
    @State private var pendingSection: SessionCardState? = nil

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

                Text("Módulos")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(height: 44)
            .padding(.top, 8)

            // MARK: Module name + title
            if !viewModel.modules.isEmpty {
                let mod = viewModel.modules[viewModel.selectedTabIndex]

                VStack(alignment: .leading, spacing: 2) {
                    Text(mod.name)
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                    Text(mod.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 6)

                // Progress bar
                let progress = viewModel.progressForModule(at: viewModel.selectedTabIndex)
                let progressPct = Int(progress * 100)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: geo.size.width * CGFloat(progress), height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                HStack {
                    Text("Progresso")
                        .font(.system(size: 12))
                    Spacer()
                    Text("\(progressPct)%")
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                Spacer().frame(height: 18)
            }

            // MARK: Tab row
            if viewModel.modules.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(viewModel.modules.indices, id: \.self) { idx in
                            let isSelected = viewModel.selectedTabIndex == idx
                            Button {
                                viewModel.selectedTabIndex = idx
                            } label: {
                                VStack(spacing: 0) {
                                    Text("\(idx + 1)")
                                        .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                                        .foregroundColor(isSelected ? Color.brandOrange : .primary)
                                        .frame(minWidth: 44, minHeight: 36)
                                        .padding(.horizontal, 4)

                                    Rectangle()
                                        .fill(isSelected ? Color.white : Color(.systemGray5))
                                        .frame(height: 3)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                }
                            }
                            .buttonStyle(.plain)
                            .background(isSelected ? Color.white : Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: isSelected ? 10 : 0,
                                                        style: .continuous))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .background(Color(.systemGray5))
            }

            // MARK: Section list
            if !viewModel.modules.isEmpty {
                let mod = viewModel.modules[viewModel.selectedTabIndex]
                let tabIdx = viewModel.selectedTabIndex
                let cards = mod.section.enumerated().map { (idx, sec) in
                    viewModel.sessionState(section: sec, sectionIndex: idx, tabIndex: tabIdx)
                }

                List {
                    ForEach(cards) { card in
                        SessionCardRow(card: card) {
                            if card.isEnabled { pendingSection = card }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                .listStyle(.plain)
                .background(Color.white)
            }
        }
        .background(Color(.systemGray6))
        .navigationBarHidden(true)
        .onAppear { viewModel.load() }
        .sheet(item: $pendingSection) { card in
            SectionConfirmSheet(card: card) {
                pendingSection = nil
                navigate(.screenSection)
            } onCancel: {
                pendingSection = nil
            }
            .presentationDetents([.fraction(0.45)])
        }
    }
}

// MARK: - SessionCardRow (MyCardItemViewSession port)

struct SessionCardRow: View {

    let card: SessionCardState
    let onTap: () -> Void

    var body: some View {
        Button(action: { if card.isEnabled { onTap() } }) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {

                    // Status icon
                    statusIcon
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .opacity(card.isEnabled ? 0.9 : 0.3)

                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.section.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                        Text(card.section.title)
                            .font(.system(size: 11))
                            .foregroundColor(.primary)
                        Text(card.section.body)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(2)

                        Spacer().frame(height: 4)

                        HStack(spacing: 6) {
                            // Time badge
                            Text(card.section.time)
                                .font(.system(size: 11))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )

                            // Status badge
                            Text(card.statusText)
                                .font(.system(size: 11))
                                .foregroundColor(statusTextColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(statusBadgeColor)
                                .clipShape(RoundedRectangle(cornerRadius: 50))
                        }
                    }

                    Spacer(minLength: 0)

                    // Arrow
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .opacity(card.isEnabled ? 1 : 0.4)
                        .frame(height: 70)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)

                Divider()
                    .padding(.horizontal, 8)
            }
        }
        .buttonStyle(.plain)
        .disabled(!card.isEnabled)
    }

    private var statusIcon: some View {
        ZStack {
            switch card.status {
            case .completed:
                Color.green.opacity(0.15)
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.green)
            case .inProgress:
                Color.orange.opacity(0.15)
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.orange)
            case .locked:
                Color(.systemGray5)
                Image(systemName: "lock.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 28)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var statusBadgeColor: Color {
        switch card.status {
        case .completed: return Color.green.opacity(0.15)
        case .inProgress: return Color.yellow.opacity(0.4)
        case .locked: return Color(.systemGray5)
        }
    }

    private var statusTextColor: Color {
        switch card.status {
        case .completed: return .green
        case .inProgress: return Color(red: 0.6, green: 0.5, blue: 0)
        case .locked: return .secondary
        }
    }
}

// MARK: - SectionConfirmSheet (MyDialogMain port)

private struct SectionConfirmSheet: View {

    let card: SessionCardState
    let onConfirm: () -> Void
    let onCancel: () -> Void

    private var subTitleText: String {
        switch card.sessaoNumero {
        case 1: return "Aprenda os fundamentos básicos."
        case 2: return "Aprofunde seu conhecimento."
        case 3: return "Avance para o próximo nível."
        case 4: return "Reforce o que você aprendeu."
        case 5: return "Aplique na prática."
        case 6: return "Integre todos os conceitos."
        case 7: return "Conquiste a sessão final do módulo!"
        default: return "Inicie esta sessão."
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 8)

            Text(card.section.name)
                .font(.system(size: 16, weight: .bold))
                .multilineTextAlignment(.center)

            Text(card.section.title)
                .font(.system(size: 18, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.brandOrange)

            Text(subTitleText)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button(action: onConfirm) {
                Text("INICIAR SESSÃO")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.brandOrange)
                    .cornerRadius(50)
            }
            .padding(.horizontal, 24)

            Button(action: onCancel) {
                Text("CANCELAR")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
    }
}
