// AppPreferences.swift
// Replaces data/local/AppPreferences.kt

import Foundation

final class AppPreferences {

    private let defaults = UserDefaults.standard

    private enum Key: String, CaseIterable {
        case userName = "app_user_name"
        case userEmail = "app_user_email"
        case birthDate = "app_birth_date"
        case hasCompletedIntro = "app_has_completed_intro"
        case gamificacaoPoints = "app_gamificacao_points"
        case iaQuantity = "app_ia_quantity"
    }

    var userName: String? {
        get { defaults.string(forKey: Key.userName.rawValue) }
        set { defaults.set(newValue, forKey: Key.userName.rawValue) }
    }

    var userEmail: String? {
        get { defaults.string(forKey: Key.userEmail.rawValue) }
        set { defaults.set(newValue, forKey: Key.userEmail.rawValue) }
    }

    var birthDate: String? {
        get { defaults.string(forKey: Key.birthDate.rawValue) }
        set { defaults.set(newValue, forKey: Key.birthDate.rawValue) }
    }

    var hasCompletedIntro: Bool {
        get { defaults.bool(forKey: Key.hasCompletedIntro.rawValue) }
        set { defaults.set(newValue, forKey: Key.hasCompletedIntro.rawValue) }
    }

    var gamificacaoPoints: Int {
        get { defaults.integer(forKey: Key.gamificacaoPoints.rawValue) }
        set { defaults.set(newValue, forKey: Key.gamificacaoPoints.rawValue) }
    }

    var iaQuantity: Int {
        get { defaults.integer(forKey: Key.iaQuantity.rawValue) }
        set { defaults.set(newValue, forKey: Key.iaQuantity.rawValue) }
    }

    func clearAll() {
        Key.allCases.forEach { defaults.removeObject(forKey: $0.rawValue) }
    }
}
