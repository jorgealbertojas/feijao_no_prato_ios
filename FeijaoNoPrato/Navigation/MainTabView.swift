// MainTabView.swift
// Replaces MainScreen + BottomNavigationBar from Android.

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var appDependencies: AppDependencies
    @StateObject private var gamificacaoViewModel = GamificacaoViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Início", systemImage: "house")
                }
                .tag(0)

            ProgressView_()
                .tabItem {
                    Label("Progresso", systemImage: "chart.bar")
                }
                .tag(1)

            ResourcesView()
                .tabItem {
                    Label("Feira", systemImage: "bag")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person")
                }
                .tag(3)
        }
        .environmentObject(gamificacaoViewModel)
    }
}

// MARK: - Tab placeholder views (will be replaced by real screen ports)

struct HomeView: View {
    var body: some View { Text("HomeView — TODO") }
}

struct ProgressView_: View {
    var body: some View { Text("ProgressView — TODO") }
}

struct ResourcesView: View {
    var body: some View { Text("ResourcesView — TODO") }
}

struct ProfileView: View {
    var body: some View { Text("ProfileView — TODO") }
}
