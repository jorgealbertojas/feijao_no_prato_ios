// AppColors.swift
// Mirrors ui/theme/Color.kt — extend as the full palette is confirmed.

import SwiftUI

extension Color {
    // Primary palette — matching the Android res/color values
    static let primary100 = Color("primary_100")     // main brand orange-red
    static let primary400 = Color("primary_400")     // lighter brand tint

    // Background
    static let carioquinaIntroduction = Color("carioquina_introdution")

    // System fallbacks (used while asset catalog colours are being added)
    static let brandOrange = Color(red: 0.792, green: 0.431, blue: 0.298)
}
