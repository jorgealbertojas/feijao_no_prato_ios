// ContentView.swift
// Root view — will be replaced by AppNavigation once all screens are ported.

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var appDependencies: AppDependencies

    var body: some View {
        AppNavigation()
            .environmentObject(appDependencies)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppDependencies())
}
