// IaFoodView.swift
// Ports ui/screens/iaFood/IaFood.kt

import SwiftUI
import PhotosUI

struct IaFoodView: View {

    var navigate: (AppRoute) -> Void
    var dismiss: (() -> Void)? = nil

    @EnvironmentObject var iaFoodViewModel: IaFoodViewModel

    @State private var showCamera = false
    @State private var galleryItem: PhotosPickerItem? = nil
    @State private var showHistoryMenu = false

    private let orange = Color(red: 0.831, green: 0.427, blue: 0.290)   // 0xFFD46D4A
    private let beige  = Color(red: 0.957, green: 0.937, blue: 0.898)   // 0xFFF4EFE5
    private let brown  = Color(red: 0.235, green: 0.208, blue: 0.176)   // 0xFF3C352D
    private let gold   = Color(red: 0.714, green: 0.663, blue: 0.533)   // 0xFFB6A988

    var body: some View {
        ZStack(alignment: .bottom) {

            beige.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .center, spacing: 0) {

                    // Top bar: back button (left) + history button (right)
                    HStack {
                        if let dismiss {
                            Button(action: dismiss) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.545, green: 0.494, blue: 0.365))
                                    .padding(12)
                            }
                        } else {
                            Spacer().frame(width: 44)
                        }
                        Spacer()
                        Button {
                            withAnimation { showHistoryMenu = true }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 20))
                                .foregroundColor(gold)
                                .padding(12)
                        }
                    }
                    .padding(.top, 8)

                    Spacer().frame(height: 32)

                    // AI icon circle (64dp with 50dp icon inside)
                    ZStack {
                        Circle()
                            .fill(orange)
                            .frame(width: 64, height: 64)
                        Image(systemName: "fork.knife.circle.fill")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                    }

                    Spacer().frame(height: 16)

                    Text("IA no Prato")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(brown)

                    Spacer().frame(height: 16)

                    Text("Vamos fazer uma análise completa\nda sua refeição?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(brown)
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: 16)

                    Text("A cada início de um novo módulo, você ganha 10 avaliações da nossa IA no Prato!\n\nÉ só tirar uma foto do seu café da manhã, almoço ou jantar e uma inteligência artificial vai analisar como sua refeição se encaixa na nossa proposta de alimentação saudável.")
                        .font(.system(size: 14))
                        .foregroundColor(brown)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 16)

                    // "Como funciona" link
                    Button { navigate(.howItWorksCard) } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(gold)
                            Text("Como funciona")
                                .font(.system(size: 14))
                                .foregroundColor(gold)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: 220)
                }
                .frame(maxWidth: .infinity)
            }

            // Bottom card — white, rounded top
            VStack(spacing: 16) {
                Button {
                    showCamera = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "camera")
                            .foregroundColor(.white)
                        Text("TIRAR FOTO")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(orange)
                    .clipShape(Capsule())
                }

                PhotosPicker(selection: $galleryItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(orange)
                        Text("SELECIONAR DA GALERIA")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(orange)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .overlay(Capsule().stroke(orange, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
        .overlay {
            if showHistoryMenu {
                HistoryMenuView(
                    isPresented: $showHistoryMenu,
                    historyItems: iaFoodViewModel.historicoIA
                )
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCamera) {
            IaFoodCameraPickerView { image in
                guard let image else { return }
                iaFoodViewModel.setSelectedImage(image)
                navigate(.confirmPhotoFromGallery)
            }
        }
        .onChange(of: galleryItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    iaFoodViewModel.setSelectedImage(image)
                    navigate(.confirmPhotoFromGallery)
                }
            }
        }
    }
}
