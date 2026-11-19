// LoginStartView.swift
// Replaces ui/screens/login/LoginStartScreen.kt

import SwiftUI

struct LoginStartView: View {

    var navigate: (AppRoute) -> Void

    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                splashView
            } else {
                loginView
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                showSplash = false
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Splash

    private var splashView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            // TODO: replace with GIF via SDWebImageSwiftUI
            Image(systemName: "leaf.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
        }
    }

    // MARK: - Login

    private var loginView: some View {
        VStack(spacing: 0) {
            Color.brandOrange
                .ignoresSafeArea(edges: .top)
                .frame(height: 0)

            VStack(spacing: 0) {
                Spacer().frame(height: 80)

                // Logo
                Image("icon_main_name")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 198)

                Spacer().frame(height: 36)

                Text("É brasileiro, é acessível, é para todos!")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 50)
            }
            .background(Color.brandOrange)

            // White card
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 24)

                    Text("Já possui cadastro?")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)

                    Spacer()

                    Button {
                        navigate(.email)
                    } label: {
                        Text("ENTRAR COM EMAIL")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 326, height: 56)
                            .background(Color.brandOrange)
                            .cornerRadius(8)
                    }

                    Text("Ainda não possui uma conta?")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)

                    Button {
                        navigate(.register)
                    } label: {
                        Text("CADASTRE-SE")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.brandOrange)
                            .frame(width: 326, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.brandOrange, lineWidth: 2)
                            )
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 32, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 32))
        }
        .background(Color.brandOrange.ignoresSafeArea())
    }
}


#Preview {
    LoginStartView(navigate: { _ in })
}
