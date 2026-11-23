// FilterView.swift
// Ports ui/myComponents/myCards/FilterScreen.kt

import SwiftUI

struct FilterView: View {

    @Binding var selected: Set<String>
    var onApply: (Set<String>) -> Void
    var onDismiss: () -> Void

    @State private var local: Set<String>

    private let categorias = [
        "O básico",
        "Cozinhando",
        "Comida e cultura",
        "Tenda Curiosa",
        "Feijuca indica e convida"
    ]

    private let primary100   = Color(red: 0.808, green: 0.447, blue: 0.341) // #CE7257
    private let primary200   = Color(red: 0.620, green: 0.278, blue: 0.180) // #9E472E
    private let quaternary11 = Color(red: 0.973, green: 0.969, blue: 0.953) // #F8F7F3
    private let buttonGray   = Color(red: 0.529, green: 0.522, blue: 0.502) // #878580

    init(selected: Binding<Set<String>>, onApply: @escaping (Set<String>) -> Void, onDismiss: @escaping () -> Void) {
        _selected = selected
        _local = State(initialValue: selected.wrappedValue)
        self.onApply = onApply
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Header
            HStack(spacing: 10) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
                Text("Filtros")
                    .font(.system(size: 20))
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 20)

            Text("Filtrar por categoria(s):")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

            // MARK: Category rows
            ForEach(categorias, id: \.self) { categoria in
                let isSelected = local.contains(categoria)
                HStack {
                    Text(categoria)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? primary200 : Color(white: 0.6))
                }
                .padding(12)
                .background(quaternary11, in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? primary200 : quaternary11, lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isSelected { local.remove(categoria) }
                    else { local.insert(categoria) }
                }
            }

            Spacer()

            // MARK: Buttons
            VStack(spacing: 10) {
                Button(action: {
                    onApply(local)
                    onDismiss()
                }) {
                    Text("APLICAR")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(local.isEmpty ? buttonGray : primary100)
                        .cornerRadius(8)
                }

                Button(action: onDismiss) {
                    Text("CANCELAR")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(primary200)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(primary200, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
