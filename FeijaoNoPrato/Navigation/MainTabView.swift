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
                    Image("icon_progress_tab")
                    Text("Progresso")
                }
                .tag(1)

            ResourcesView(navigate: navigate)
                .tabItem {
                    Image("icon_feira_tab")
                    Text("Feira")
                }
                .tag(2)

            // Prato tab — mirrors Android "Prato" (IaFood) tab
            IaFoodView(navigate: navigate, dismiss: nil)
                .environmentObject(iaFoodViewModel)
                .tabItem {
                    Image("icon_prato_tab")
                    Text("Prato")
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
