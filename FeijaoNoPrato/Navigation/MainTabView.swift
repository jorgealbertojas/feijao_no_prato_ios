// MainTabView.swift
// Replaces MainScreen + BottomNavigationBar from Android.
//
// NOTE: The IA tab does NOT use a nested NavigationStack — nesting NavigationStacks
// inside the outer one in AppNavigation causes SwiftUI to pop back to the root on tab switch.
// All IA-route pushes go through the outer navigation's `navigate` callback.

import SwiftUI

struct MainTabView: View {

    var navigate: (AppRoute) -> Void
    var onLogout: () -> Void

    @EnvironmentObject var appDependencies: AppDependencies
    @EnvironmentObject var gamificacaoViewModel: GamificacaoViewModel
    @EnvironmentObject var iaFoodViewModel: IaFoodViewModel

    var body: some View {
        TabView {
            HomeView(navigate: navigate)
                .tabItem {
                    Label("Início", systemImage: "house")
                }
                .tag(0)

            ProgressView_(navigate: navigate)
                .tabItem {
                    Label("Progresso", systemImage: "chart.bar")
                }
                .tag(1)

            ResourcesView(navigate: navigate)
                .tabItem {
                    Label("Feira", systemImage: "bag")
                }
                .tag(2)

            // IA tab — uses outer navigate so pushes go onto the outer NavigationStack
            IaFoodView(navigate: navigate, dismiss: nil)
                .environmentObject(iaFoodViewModel)
                .tabItem {
                    Label("IA", systemImage: "brain.head.profile")
                }
                .tag(3)

            ProfileView(navigate: navigate, onLogout: onLogout, appDependencies: appDependencies)
                .tabItem {
                    Label("Perfil", systemImage: "person")
                }
                .tag(4)
        }
        .onAppear {
            // Re-sync backend pontuação every time the main tabs appear.
            // setup() fires at AppNavigation.onAppear which may run before the user
            // completes login — this call ensures a fresh sync after the token is set.
            gamificacaoViewModel.carregar()
        }
    }
}
