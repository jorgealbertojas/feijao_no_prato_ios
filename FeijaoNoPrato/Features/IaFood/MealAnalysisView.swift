// MealAnalysisView.swift
// Ports ui/screens/iaFood/MealAnalysisScreen.kt

import SwiftUI
import PhotosUI

struct MealAnalysisView: View {

    var navigate: (AppRoute) -> Void
    var dismiss: () -> Void

    @EnvironmentObject var iaFoodViewModel: IaFoodViewModel

    @State private var galleryItem: PhotosPickerItem? = nil
    @State private var showCamera = false

    // 0xFFB96E44 — orange used in loading text and home FAB
    private let orangeDeep = Color(red: 0.725, green: 0.431, blue: 0.267)
    // 0xFFB49F6D — muted gold for bottom icon buttons
    private let gold       = Color(red: 0.706, green: 0.624, blue: 0.427)
    // 0xFFF4EFE5 — beige background for result state
    private let beige      = Color(red: 0.957, green: 0.937, blue: 0.898)

    var body: some View {
        let isAnalyzing = iaFoodViewModel.analysisState == .analyzing

        ZStack(alignment: .bottom) {
            // Background: white while loading, beige for result/error
            (isAnalyzing ? Color.white : beige)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 8)

                    // Photo centered
                    if let image = iaFoodViewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Spacer().frame(height: 24)

                    // State content
                    switch iaFoodViewModel.analysisState {
                    case .idle:
                        EmptyView()

                    case .analyzing:
                        HStack(alignment: .top, spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(orangeDeep)
                            Text("Nossa IA está examinando sua refeição. A análise estará pronta em um minuto…")
                                .font(.system(size: 14))
                                .foregroundColor(orangeDeep)
                        }
                        .padding(.horizontal, 24)

                    case .success(let text):
                        Text(parseFormatted(text))
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 88)

                    case .error(let message):
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 88)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // Bottom bar — white, rounded top
            HStack(spacing: 0) {
                // Camera
                Button {
                    showCamera = true
                } label: {
                    Image(systemName: "camera")
                        .font(.system(size: 22))
                        .foregroundColor(gold)
                        .frame(width: 48, height: 48)
                }

                // Gallery
                PhotosPicker(selection: $galleryItem, matching: .images) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 22))
                        .foregroundColor(gold)
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.plain)

                Spacer()

                // Home FAB
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "house.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(orangeDeep)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
            )
        }
        .navigationBarHidden(true)
        .task {
            await iaFoodViewModel.analyzeSelectedImage()
        }
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

    private func parseFormatted(_ raw: String) -> AttributedString {
        var result = AttributedString()
        let parts = raw.components(separatedBy: "**")
        for (i, part) in parts.enumerated() {
            var seg = AttributedString(part)
            if i % 2 == 1 {
                seg.font = .system(size: 14, weight: .bold)
            }
            result.append(seg)
        }
        return result
    }
}
