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

    // Resources / Feira
    case resourceList(title: String, items: [ResourceItem])
    case resourceDetail(item: ResourceItem, isAvailable: Bool)
    // Direct Feira navigation from module content (mirrors Android ?categoriaFiltro= param)
    case resourcesFiltered(categoria: String)

    // Profile text pages
    case profileText(title: String)

    // Web
    case webView(url: String)
}

struct AppNavigation: View {

    @EnvironmentObject var appDependencies: AppDependencies
    @State private var path: NavigationPath
    @StateObject private var iaFoodViewModel = IaFoodViewModel()
    @StateObject private var gamificacaoViewModel = GamificacaoViewModel()

    // Start at home if the user already has a saved token (mirrors Android startDestination logic)
    init() {
        let authPrefs = AuthPreferences()
        if authPrefs.isLoggedIn, authPrefs.token != nil {
            var initial = NavigationPath()
            initial.append(AppRoute.home)
            _path = State(initialValue: initial)
        } else {
            _path = State(initialValue: NavigationPath())
        }
    }

    // Replace current route — mirrors NavController.navigateReplacing
    private func navigateReplacing(_ route: AppRoute) {
        if !path.isEmpty { path.removeLast() }
        path.append(route)
    }

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
        .onAppear {
            gamificacaoViewModel.setup(repository: appDependencies.gamificacaoRepository)
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
            Introduction1View(initialScreen: n, navigate: navigateReplacing)
        case .introduction2(let n):
            Introduction2View(initialScreen: n, navigate: navigateReplacing)
        case .introduction3(let n):
            Introduction3View(initialScreen: n, navigate: navigateReplacing)
        case .introduction4(let n):
            Introduction4View(initialScreen: n, navigate: navigateReplacing)
        case .introduction5(let n):
            Introduction5View(initialScreen: n, navigate: navigateReplacing)
        case .introduction6(let n):
            Introduction6View(initialScreen: n, navigate: navigateReplacing)
        case .introduction7(let n):
            Introduction7View(initialScreen: n, navigate: navigateReplacing)
        case .home, .profile, .progress, .resources:
            MainTabView(
                navigate: { path.append($0) },
                onLogout: { path.removeLast(path.count) }
            )
            .environmentObject(iaFoodViewModel)
            .environmentObject(gamificacaoViewModel)
        case .screenModule:
            ScreenModuleView(
                navigate: { path.append($0) },
                dismiss: { path.removeLast() }
            )
        case .screenSection:
            ScreenSectionView(
                navigate: { path.append($0) },
                dismiss: { path.removeLast() }
            )
            .environmentObject(gamificacaoViewModel)
        case .moduleDetail:
            ModuleDetailView(dismiss: { path.removeLast() })
        case .gamificacao:
            GamificacaoView(dismiss: { path.removeLast() })
        case .takePhoto, .food:
            IaFoodView(navigate: { path.append($0) }, dismiss: { path.removeLast() })
                .environmentObject(iaFoodViewModel)
        case .confirmPhotoFromGallery:
            ConfirmPhotoView(navigate: { path.append($0) }, dismiss: { path.removeLast() })
                .environmentObject(iaFoodViewModel)
                .environmentObject(gamificacaoViewModel)
                .environmentObject(appDependencies)
        case .mealAnalysis:
            MealAnalysisView(navigate: { path.append($0) }, dismiss: { path.removeLast(path.count) })
                .environmentObject(iaFoodViewModel)
        case .howItWorksCard:
            HowItWorksView(dismiss: { path.removeLast() })
        case .attachFood:
            IaFoodView(navigate: { path.append($0) }, dismiss: { path.removeLast() })
                .environmentObject(iaFoodViewModel)
        case .history:
            HistoricoFeijoesView(dismiss: { path.removeLast() })
                .environmentObject(gamificacaoViewModel)
        case .resourcesFiltered(let categoria):
            ResourcesView(
                navigate: { path.append($0) },
                dismiss: { path.removeLast() },
                initialCategoria: categoria.isEmpty ? nil : categoria
            )
            .environmentObject(gamificacaoViewModel)
            .environmentObject(appDependencies)
        case .resourceList(let title, let items):
            ResourceListView(
                title: title,
                items: items,
                navigate: { path.append($0) },
                dismiss: { path.removeLast() }
            )
            .environmentObject(gamificacaoViewModel)
            .environmentObject(appDependencies)
        case .resourceDetail(let item, let isAvailable):
            ResourceDetailView(
                item: item,
                isAvailable: isAvailable,
                dismiss: { path.removeLast() },
                navigate: { path.append($0) }
            )
            .environmentObject(gamificacaoViewModel)
            .environmentObject(appDependencies)
        case .profileText(let title):
            ProfileTextView(title: title, dismiss: { path.removeLast() })
        case .webView(let url):
            WebViewScreen(url: url)
        }
    }
}
