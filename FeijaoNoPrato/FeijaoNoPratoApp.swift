// FeijaoNoPratoApp.swift

import SwiftUI

@main
struct FeijaoNoPratoApp: App {

    @StateObject private var appDependencies = AppDependencies()

    init() {
        configureTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDependencies)
        }
    }

    // Tab bar colors matching Android BottomBar.kt:
    // selected   → primary_200 = #9E472E  (applied via SwiftUI .tint() in MainTabView)
    // unselected → neutral_200 = #C5B799
    private func configureTabBarAppearance() {
        let unselected = UIColor(red: 0.773, green: 0.718, blue: 0.600, alpha: 1) // #C5B799

        let item = UITabBarItemAppearance()
        item.normal.iconColor = unselected
        item.normal.titleTextAttributes = [.foregroundColor: unselected]

        let bar = UITabBarAppearance()
        bar.configureWithOpaqueBackground()
        bar.backgroundColor = .white
        bar.stackedLayoutAppearance       = item
        bar.inlineLayoutAppearance        = item
        bar.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance   = bar
        UITabBar.appearance().scrollEdgeAppearance = bar
    }
}
