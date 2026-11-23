// ConfirmPhotoView.swift
// Ports ui/screens/iaFood/ConfirmPhotoFromGalleryScreen.kt

import SwiftUI
import PhotosUI

struct ConfirmPhotoView: View {

    var navigate: (AppRoute) -> Void
    var dismiss: () -> Void

    @EnvironmentObject var iaFoodViewModel: IaFoodViewModel
    @EnvironmentObject var gamificacaoViewModel: GamificacaoViewModel
    @EnvironmentObject var appDependencies: AppDependencies

    @State private var showCreditInfoAlert = false
    @State private var showBuyAlert = false
    @State private var galleryItem: PhotosPickerItem? = nil

    private let orange = Color(red: 0.831, green: 0.427, blue: 0.290)   // 0xFFD46D4A
    private let beige  = Color(red: 0.957, green: 0.937, blue: 0.898)   // 0xFFF4EFE5

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {

                Spacer().frame(height: 32)

                // Photo + X button
                ZStack(alignment: .topTrailing) {
                    if let image = iaFoodViewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5))
                            .frame(width: 220, height: 220)
                    }

                    Button {
                        iaFoodViewModel.clearSelectedImage()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .offset(x: 10, y: -10)
                }

                Spacer().frame(height: 24)

                // Meal selector label
                Text("Qual foi a refeição?")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 24)

                Spacer().frame(height: 16)

                // Meal buttons
                HStack(spacing: 8) {
                    ForEach(["Café da Manhã", "Almoço", "Jantar"], id: \.self) { meal in
                        IaMealOptionButton(
                            label: meal,
                            icon: iconForMeal(meal),
                            isSelected: iaFoodViewModel.selectedMeal == meal
                        ) {
                            iaFoodViewModel.updateSelectedMeal(meal)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Meat substitute — only for Almoço/Jantar
                if iaFoodViewModel.pedeSubstitutoDeCarne {
                    Spacer().frame(height: 12)

                    VStack(alignment: .leading, spacing: 12) {
                        Spacer().frame(height: 12)

                        Text("Possui algum substituto de carne?")
                            .font(.system(size: 18, weight: .bold))

                        Text("(p.e. carne de soja, hambúrguer de lentilha/grão de bico etc)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 24)

                    HStack(spacing: 16) {
                        ForEach(["Sim", "Não"], id: \.self) { option in
                            IaOptionButton(
                                label: option,
                                isSelected: iaFoodViewModel.meatSubstitute == option
                            ) {
                                iaFoodViewModel.updateMeatSubstitute(option)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 18)

                // Send button + credits badge
                ZStack(alignment: .topTrailing) {
                    let qty = iaFoodViewModel.iaQuantity

                    if qty > 0 {
                        Button {
                            if iaFoodViewModel.canSend {
                                iaFoodViewModel.analysisState = .idle
                                navigate(.mealAnalysis)
                            }
                        } label: {
                            Text("ENVIAR")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(iaFoodViewModel.canSend ? orange : Color(.systemGray3))
                                .clipShape(Capsule())
                        }
                        .disabled(!iaFoodViewModel.canSend)
                    } else {
                        Button { showBuyAlert = true } label: {
                            Text("COMPRAR FOTO IA")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(.systemGray3))
                                .clipShape(Capsule())
                        }
                    }

                    // Badge — always visible, gray when 0
                    Button { showCreditInfoAlert = true } label: {
                        Text("\(iaFoodViewModel.iaQuantity)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(iaFoodViewModel.iaQuantity > 0 ? orange : Color(.systemGray3))
                            .clipShape(Circle())
                    }
                    .offset(x: 6, y: -10)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 32)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Avaliações disponíveis", isPresented: $showCreditInfoAlert) {
            Button("Fechar", role: .cancel) {}
        } message: {
            Text("Este número indica quantas avaliações você ainda pode realizar com a IA no Prato. A cada novo módulo iniciado, você recebe 10 avaliações, que são acumuladas às que ainda estiverem disponíveis. A cada prato avaliado, uma avaliação é descontada.")
        }
        .alert("Comprar avaliações de IA", isPresented: $showBuyAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Confirmar") {
                let ok = gamificacaoViewModel.registrarRescue(
                    numero: 9999,
                    quantidade: 20,
                    repository: appDependencies.gamificacaoRepository
                )
                if ok {
                    appDependencies.appPreferences.iaQuantity += 1
                    iaFoodViewModel.reloadIAQuantity()
                }
            }
        } message: {
            Text("Deseja gastar 20 feijões para obter 1 avaliação IA?\n\nSaldo: \(gamificacaoViewModel.pontuacao.saldo) feijões")
        }
        .onChange(of: galleryItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    iaFoodViewModel.setSelectedImage(image)
                }
            }
        }
    }

    private func iconForMeal(_ meal: String) -> String {
        switch meal {
        case "Café da Manhã": return "cup.and.saucer.fill"
        case "Almoço": return "fork.knife"
        default: return "moon.stars.fill"
        }
    }
}

// MARK: - IaMealOptionButton
// Ports MealOptionButton.kt — 103×120dp, beige background, orange border when selected

struct IaMealOptionButton: View {

    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    private let orange = Color(red: 0.831, green: 0.427, blue: 0.290)
    private let beige  = Color(red: 0.957, green: 0.937, blue: 0.898)
    private let gold   = Color(red: 0.714, green: 0.663, blue: 0.533)
    private let brown  = Color(red: 0.235, green: 0.208, blue: 0.176)

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? orange : gold)

                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? orange : brown)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 103, height: 120)
            .background(beige)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? orange : beige, lineWidth: 1)
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - IaOptionButton
// Sim / Não selection button

struct IaOptionButton: View {

    let label: String
    let isSelected: Bool
    let action: () -> Void

    private let orange = Color(red: 0.831, green: 0.427, blue: 0.290)

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? orange : Color(.secondaryLabel))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isSelected ? orange.opacity(0.08) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(isSelected ? orange : Color(.separator), lineWidth: isSelected ? 2 : 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
