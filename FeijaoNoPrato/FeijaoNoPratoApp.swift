// FeijaoNoPratoApp.swift

import SwiftUI

@main
struct FeijaoNoPratoApp: App {

    @StateObject private var appDependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDependencies)
        }
    }

}
