// ProfileViewModel.swift
// Replaces ui/screens/profile/ProfileViewModel.kt

import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var birthDate: String = ""
    @Published var profilePhoto: UIImage? = nil
    @Published var isLoading: Bool = false

    // Sheet / alert visibility
    @Published var showEditNameSheet: Bool = false
    @Published var editingName: String = ""
    @Published var showLogoutAlert: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var showPhotoMenu: Bool = false

    // Camera picker state
    @Published var showCameraPicker: Bool = false
    @Published var showGalleryPicker: Bool = false
    @Published var showBirthDatePicker: Bool = false
    @Published var galleryItem: PhotosPickerItem? = nil {
        didSet { Task { await loadGalleryItem() } }
    }

    var onLogout: (() -> Void)?

    private let appPreferences: AppPreferences
    private let authRepository: AuthRepository

    private static let photoKey = "profile_photo_data"

    init(appPreferences: AppPreferences, authRepository: AuthRepository) {
        self.appPreferences = appPreferences
        self.authRepository = authRepository
        loadUserData()
    }

    // MARK: - Load

    func loadUserData() {
        userName = appPreferences.userName ?? ""
        email = appPreferences.userEmail ?? ""
        birthDate = appPreferences.birthDate ?? ""
        if let data = UserDefaults.standard.data(forKey: Self.photoKey),
           let image = UIImage(data: data) {
            profilePhoto = image
        }
    }

    // MARK: - Edit name

    func openEditName() {
        editingName = userName
        showEditNameSheet = true
    }

    func saveName() {
        let trimmed = editingName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        userName = trimmed
        appPreferences.userName = trimmed
        showEditNameSheet = false
    }

    // MARK: - Birth date

    func saveBirthDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formatted = formatter.string(from: date)
        birthDate = formatted
        appPreferences.birthDate = formatted
        showBirthDatePicker = false
    }

    // MARK: - Photo

    private func loadGalleryItem() async {
        guard let item = galleryItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            setPhoto(image)
        }
        galleryItem = nil
    }

    func setPhoto(_ image: UIImage) {
        profilePhoto = image
        if let data = image.jpegData(compressionQuality: 0.7) {
            UserDefaults.standard.set(data, forKey: Self.photoKey)
        }
    }

    func removePhoto() {
        profilePhoto = nil
        UserDefaults.standard.removeObject(forKey: Self.photoKey)
    }

    // MARK: - Logout / Delete

    func logout() {
        authRepository.logout()
        onLogout?()
    }

    func deleteAccount() {
        authRepository.logout()
        onLogout?()
    }
}
