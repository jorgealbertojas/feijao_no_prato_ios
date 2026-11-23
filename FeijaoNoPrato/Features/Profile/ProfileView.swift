// ProfileView.swift
// Ports ui/screens/profile/ProfileScreen.kt + ColorSplitCardWithCircleImage.kt + CustomCardViewEndArrow.kt

import SwiftUI
import PhotosUI

// MARK: - Main Profile View

struct ProfileView: View {

    var navigate: (AppRoute) -> Void
    var onLogout: () -> Void

    @EnvironmentObject var appDependencies: AppDependencies
    @StateObject private var viewModel: ProfileViewModel

    // Date picker state
    @State private var selectedDate: Date = Date()

    init(navigate: @escaping (AppRoute) -> Void, onLogout: @escaping () -> Void, appDependencies: AppDependencies) {
        self.navigate = navigate
        self.onLogout = onLogout
        _viewModel = StateObject(wrappedValue: ProfileViewModel(
            appPreferences: appDependencies.appPreferences,
            authRepository: appDependencies.authRepository
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 70)

                // MARK: Profile card (ColorSplitCardWithCircleImage)
                ProfileCardView(viewModel: viewModel)
                    .padding(.top, 10)

                // MARK: Menu card
                VStack(spacing: 0) {
                    ProfileMenuRow(label: "Sobre") {
                        navigate(.profileText(title: "Sobre"))
                    }
                    Divider().padding(.leading, 16)
                    ProfileMenuRow(label: "Perguntas frequentes (FAQ)") {
                        navigate(.profileText(title: "Perguntas frequentes (FAQ)"))
                    }
                    Divider().padding(.leading, 16)
                    ProfileMenuRow(label: "Termos e condições de uso") {
                        navigate(.profileText(title: "Termos e condições de uso"))
                    }
                    Divider().padding(.leading, 16)
                    ProfileMenuRow(label: "Política de privacidade") {
                        navigate(.profileText(title: "Política de privacidade"))
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // MARK: Logout button
                Button {
                    viewModel.showLogoutAlert = true
                } label: {
                    Text("DESLOGAR")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)

                // MARK: Delete account button
                Button {
                    viewModel.showDeleteAlert = true
                } label: {
                    Text("EXCLUIR CONTA")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 0.718, green: 0.110, blue: 0.110)) // 0xFFB71C1C
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onLogout = onLogout
        }

        // MARK: Edit name alert
        .alert("Alterar nome", isPresented: $viewModel.showEditNameSheet) {
            TextField("Nome", text: $viewModel.editingName)
            Button("Salvar") { viewModel.saveName() }
            Button("Cancelar", role: .cancel) {}
        }

        // MARK: Date picker sheet
        .sheet(isPresented: $viewModel.showBirthDatePicker) {
            BirthDatePickerSheet(date: $selectedDate) {
                viewModel.saveBirthDate(selectedDate)
            } onDismiss: {
                viewModel.showBirthDatePicker = false
            }
            .presentationDetents([.height(380)])
        }

        // MARK: Logout alert
        .alert("Sair da conta?", isPresented: $viewModel.showLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Sair", role: .destructive) { viewModel.logout() }
        } message: {
            Text("Você será redirecionado para a tela de login.")
        }

        // MARK: Delete alert
        .alert("Excluir conta", isPresented: $viewModel.showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) { viewModel.deleteAccount() }
        } message: {
            Text("Sua conta será marcada como excluída no serviço e você será deslogado deste aparelho.")
        }

        // MARK: Camera picker
        .sheet(isPresented: $viewModel.showCameraPicker) {
            CameraPickerView { image in
                if let image { viewModel.setPhoto(image) }
                viewModel.showCameraPicker = false
            }
            .ignoresSafeArea()
        }

        // MARK: Gallery picker (triggered from avatar confirmation dialog)
        .photosPicker(isPresented: $viewModel.showGalleryPicker, selection: $viewModel.galleryItem, matching: .images)
    }
}

// MARK: - Profile Card (ColorSplitCardWithCircleImage)

private struct ProfileCardView: View {

    @ObservedObject var viewModel: ProfileViewModel

    private let cardHeight: CGFloat = 340
    private let topHeight: CGFloat = 130
    private let avatarSize: CGFloat = 100
    private let topColor = Color(red: 0.937, green: 0.843, blue: 0.702)  // quaternary_100 = #efd7b3
    private let primaryOrange = Color(red: 0.808, green: 0.447, blue: 0.341)  // primary_100 = #CE7257

    var body: some View {
        Card {
            ZStack(alignment: .top) {
                // Split background
                VStack(spacing: 0) {
                    topColor.frame(height: topHeight)
                    Color.white.frame(height: cardHeight - topHeight)
                }

                // "Meu Perfil" title
                Text("Meu Perfil")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity)

                // Bottom content column, offset to start below avatar
                VStack(spacing: 0) {
                    Spacer().frame(height: topHeight + avatarSize / 2 + 20)

                    // Name row
                    HStack(spacing: 8) {
                        Text(viewModel.userName.isEmpty ? "Nome" : viewModel.userName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                        Button {
                            viewModel.openEditName()
                        } label: {
                            Text(viewModel.userName.isEmpty ? "Cadastrar" : "Alterar")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }

                    // Email
                    Text(viewModel.email)
                        .font(.system(size: 17))
                        .foregroundColor(primaryOrange)
                        .padding(.top, 16)

                    Spacer().frame(height: 24)

                    // Photo action links
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $viewModel.galleryItem, matching: .images) {
                            Text("Alterar foto")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(primaryOrange)
                        }
                        .buttonStyle(.plain)

                        Button {
                            viewModel.removePhoto()
                        } label: {
                            Text("Remover foto")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer().frame(height: 14)

                    // Birth date row
                    HStack(spacing: 8) {
                        Text(viewModel.birthDate.isEmpty ? "Data de nascimento" : viewModel.birthDate)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                        Button {
                            viewModel.showBirthDatePicker = true
                        } label: {
                            Text(viewModel.birthDate.isEmpty ? "Cadastrar" : "Alterar")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)

                // Avatar overlapping the split, centered
                VStack {
                    AvatarView(viewModel: viewModel, avatarSize: avatarSize)
                        .padding(.top, topHeight - avatarSize / 2)
                    Spacer()
                }
            }
            .frame(height: cardHeight)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Avatar

private struct AvatarView: View {

    @ObservedObject var viewModel: ProfileViewModel
    let avatarSize: CGFloat

    @State private var showMenu = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: avatarSize, height: avatarSize)

            if let photo = viewModel.profilePhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: avatarSize - 10, height: avatarSize - 10)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: avatarSize * 0.5, height: avatarSize * 0.5)
                    .foregroundColor(Color(red: 0.773, green: 0.718, blue: 0.600))  // icon_profile = #C5B799
            }
        }
        .onTapGesture { showMenu = true }
        .confirmationDialog("Foto de perfil", isPresented: $showMenu, titleVisibility: .hidden) {
            Button("Escolher da galeria") {
                // Trigger PhotosPicker via viewModel flag — handled by sheet in parent
                viewModel.showGalleryPicker = true
            }
            Button("Tirar foto") {
                viewModel.showCameraPicker = true
            }
            Button("Deletar foto", role: .destructive) {
                viewModel.removePhoto()
            }
            Button("Cancelar", role: .cancel) {}
        }
    }
}

// MARK: - Menu Row (CustomCardViewEndArrow)

private struct ProfileMenuRow: View {

    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.541, green: 0.486, blue: 0.373))  // icon_arrow_link = #8A7C5F
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Birth Date Picker Sheet

private struct BirthDatePickerSheet: View {

    @Binding var date: Date
    let onSave: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Data de nascimento")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                }
            }

            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()

            Button(action: onSave) {
                Text("Salvar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.792, green: 0.431, blue: 0.298))
                    .cornerRadius(8)
            }
        }
        .padding(24)
    }
}

// MARK: - Card helper (matches Android Card with elevation)

private struct Card<Content: View>: View {

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Camera Picker (UIImagePickerController wrapper)

struct CameraPickerView: UIViewControllerRepresentable {

    let completion: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completion: (UIImage?) -> Void
        init(completion: @escaping (UIImage?) -> Void) { self.completion = completion }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            completion(info[.originalImage] as? UIImage)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completion(nil)
        }
    }
}
