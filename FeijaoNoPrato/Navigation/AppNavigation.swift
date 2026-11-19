// AppNavigation.swift
// Root navigation — mirrors Navigation.kt + AppRoutes.kt

import SwiftUI

enum AppRoute: Hashable {
    // Auth
    case start
    case email
    case verify(email: String)
    case register

    // Intro
    case introduction1(screen: Int)
    case introduction2(screen: Int)
    case introduction3(screen: Int)
    case introduction4(screen: Int)
    case introduction5(screen: Int)
    case introduction6(screen: Int)
    case introduction7(screen: Int)

    // Main tabs
    case home
    case profile
    case progress
    case resources
    case food

    // Module / section
    case screenModule
    case screenSection
    case moduleDetail(id: Int)

    // Gamification
    case gamificacao

    // AI Food
    case takePhoto
    case howItWorksCard
    case mealAnalysis
    case confirmPhotoFromGallery
    case attachFood
    case history

    // Web
    case webView(url: String)
}

struct AppNavigation: View {

    @EnvironmentObject var appDependencies: AppDependencies
    @State private var path = NavigationPath()

    private func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            authRepository: appDependencies.authRepository,
            appPreferences: appDependencies.appPreferences
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            // Start at the login/splash screen
            LoginStartView(navigate: { route in
                path.append(route)
            })
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .start:
            LoginStartView(navigate: { path.append($0) })
        case .email:
            EmailInputView(
                navigate: { path.append($0) },
                dismiss: { path.removeLast() },
                viewModel: makeAuthViewModel()
            )
        case .verify(let email):
            CodeVerificationView(
                email: email,
                onSuccess: { route in
                    path.removeLast(path.count)
                    path.append(route)
                },
                dismiss: { path.removeLast() },
                isRegisterFlow: false,
                viewModel: makeAuthViewModel()
            )
        case .register:
            ScreenRegisterView(
                navigate: { route in
                    path.removeLast(path.count)
                    path.append(route)
                },
                dismiss: { path.removeLast() },
                viewModel: makeAuthViewModel()
            )
        case .introduction1(let n):
            Text("Introduction1(\(n)) — TODO")
        case .introduction2(let n):
            Text("Introduction2(\(n)) — TODO")
        case .introduction3(let n):
            Text("Introduction3(\(n)) — TODO")
        case .introduction4(let n):
            Text("Introduction4(\(n)) — TODO")
        case .introduction5(let n):
            Text("Introduction5(\(n)) — TODO")
        case .introduction6(let n):
            Text("Introduction6(\(n)) — TODO")
        case .introduction7(let n):
            Text("Introduction7(\(n)) — TODO")
        case .home, .profile, .progress, .resources, .food:
            MainTabView()
        case .screenModule:
            Text("ScreenModule — TODO")
        case .screenSection:
            Text("ScreenSection — TODO")
        case .moduleDetail(let id):
            Text("ModuleDetail(\(id)) — TODO")
        case .gamificacao:
            Text("GamificacaoView — TODO")
        case .takePhoto, .howItWorksCard, .mealAnalysis, .confirmPhotoFromGallery, .attachFood:
            Text("AI Food screens — TODO")
        case .history:
            Text("HistoryMenuView — TODO")
        case .webView(let url):
            Text("WebView(\(url)) — TODO")
        }
    }
}
