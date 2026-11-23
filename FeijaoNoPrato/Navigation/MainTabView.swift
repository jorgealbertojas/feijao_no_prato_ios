// MainTabView.swift
// Replaces MainScreen + BottomNavigationBar from Android.
//
// NOTE: The IA tab does NOT use a nested NavigationStack — nesting NavigationStacks
// inside the outer one in AppNavigation causes SwiftUI to pop back to the root on tab switch.
// All IA-route pushes go through the outer navigation's `navigate` callback.
//
// NOTE: Uses a custom tab bar instead of SwiftUI's TabView tabItem{} because
// iOS 18 SwiftUI TabView does not apply UITabBarAppearance tinting to tabItem icons.
// foregroundColor() on Image with renderingMode(.template) is the reliable way to
// set selected (#9E472E) / unselected (#C5B799) icon colors matching Android BottomBar.kt.

import SwiftUI

private struct BottomTabItem {
    let icon: String
    let label: String
}

private let tabItems: [BottomTabItem] = [
    .init(icon: "icon_home_tab",     label: "Início"),
    .init(icon: "icon_progress_tab", label: "Progresso"),
    .init(icon: "icon_feira_tab",    label: "Feira"),
    .init(icon: "icon_prato_tab",    label: "Prato"),
    .init(icon: "icon_profile_tab",  label: "Perfil"),
]

// Android primary_200
private let selectedColor   = Color(red: 0.620, green: 0.278, blue: 0.180)
// Android neutral_200
private let unselectedColor = Color(red: 0.773, green: 0.718, blue: 0.600)

struct MainTabView: View {

    var navigate: (AppRoute) -> Void
    var onLogout: () -> Void

    @EnvironmentObject var appDependencies: AppDependencies
    @EnvironmentObject var gamificacaoViewModel: GamificacaoViewModel
    @EnvironmentObject var iaFoodViewModel: IaFoodViewModel

    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // All tab content kept alive via opacity — mirrors system TabView behaviour
            ZStack {
                HomeView(navigate: navigate)
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)

                ProgressView_(navigate: navigate)
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)

                ResourcesView(navigate: navigate)
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 2)

                IaFoodView(navigate: navigate, dismiss: nil)
                    .environmentObject(iaFoodViewModel)
                    .opacity(selectedTab == 3 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 3)

                ProfileView(navigate: navigate, onLogout: onLogout, appDependencies: appDependencies)
                    .opacity(selectedTab == 4 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 49) // reserve space for the custom tab bar

            // Custom tab bar — matches Android BottomBar.kt colors exactly
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 0) {
                    ForEach(tabItems.indices, id: \.self) { idx in
                        let item = tabItems[idx]
                        let isSelected = selectedTab == idx
                        Button {
                            selectedTab = idx
                        } label: {
                            VStack(spacing: 4) {
                                Image(item.icon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text(item.label)
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(isSelected ? selectedColor : unselectedColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Color.white)
                .padding(.bottom, 20) // above home indicator
            }
            .background(Color.white)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            gamificacaoViewModel.carregar()
        }
    }
}
