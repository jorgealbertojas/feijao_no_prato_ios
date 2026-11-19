// AuthPreferences.swift
// Replaces data/local/AuthPreferences.kt — UserDefaults wrapper for auth data.

import Foundation

final class AuthPreferences {

    private let defaults = UserDefaults.standard

    private enum Key: String, CaseIterable {
        case token = "auth_token"
        case email = "auth_email"
        case isLoggedIn = "auth_is_logged_in"
    }

    var token: String? {
        get { defaults.string(forKey: Key.token.rawValue) }
        set { defaults.set(newValue, forKey: Key.token.rawValue) }
    }

    var email: String? {
        get { defaults.string(forKey: Key.email.rawValue) }
        set { defaults.set(newValue, forKey: Key.email.rawValue) }
    }

    var isLoggedIn: Bool {
        get { defaults.bool(forKey: Key.isLoggedIn.rawValue) }
        set { defaults.set(newValue, forKey: Key.isLoggedIn.rawValue) }
    }

    func clearAll() {
        Key.allCases.forEach { defaults.removeObject(forKey: $0.rawValue) }
    }
}

