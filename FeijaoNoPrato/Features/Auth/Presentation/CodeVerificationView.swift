// CodeVerificationView.swift
// Replaces ui/screens/login/CodeVerificationScreen.kt

import SwiftUI

struct CodeVerificationView: View {

    let email: String
    var onSuccess: (AppRoute) -> Void   // .home or .introduction1(1)
    var dismiss: () -> Void
    var isRegisterFlow: Bool = false    // true → navigate to intro, false → home

    @ObservedObject var viewModel: AuthViewModel

    @State private var digits = Array(repeating: "", count: 6)
    @State private var showError = false
    @State private var showResent = false
    @FocusState private var focusedIndex: Int?

    private var allFilled: Bool { digits.allSatisfy { !$0.isEmpty } }
    private var fullCode: String { digits.joined() }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white.ignoresSafeArea()

            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(24)
            }

            VStack(spacing: 24) {
                Spacer()

                Text("Você recebeu um código por e-mail.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("Enviamos o código de verificação para o seu e-mail. Verifique seu e-mail e insira o código abaixo:")
                    .font(.system(size: 18))
                    .foregroundColor(Color(white: 0.4))
                    .multilineTextAlignment(.center)

                // 6-digit OTP row
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { i in
                        TextField("", text: $digits[i])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 48, height: 56)
                            .background(Color(white: 0.973))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(focusedIndex == i ? Color.brandOrange : Color(white: 0.8), lineWidth: 1)
                            )
                            .cornerRadius(8)
                            .focused($focusedIndex, equals: i)
                            .onChange(of: digits[i]) { newVal in
                                handleInput(index: i, newVal: newVal)
                            }
                    }
                }
                .onAppear { focusedIndex = 0 }

                if showError {
                    Text("Erro ao fazer login. Tente novamente.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                if showResent {
                    Text("Código reenviado novamente.")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                // Resend
                Button {
                    Task {
                        showResent = false
                        let ok = await viewModel.requestAccessCode(email: email)
                        showResent = ok
                    }
                } label: {
                    Text("REENVIAR CÓDIGO")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.827, green: 0.42, blue: 0.302))
                        .frame(width: 326, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color(red: 0.827, green: 0.42, blue: 0.302), lineWidth: 1)
                        )
                }

                // Confirm
                Button {
                    guard allFilled else { return }
                    Task {
                        showError = false
                        let success = await viewModel.login(email: email, code: fullCode)
                        if success {
                            let destination: AppRoute = isRegisterFlow ? .introduction1(screen: 1) : .home
                            onSuccess(destination)
                        } else {
                            showError = true
                        }
                    }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("CONFIRMAR")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 326, height: 56)
                    .background(allFilled ? Color.brandOrange : Color(white: 0.8))
                    .clipShape(Capsule())
                }
                .disabled(!allFilled || viewModel.isLoading)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .navigationBarHidden(true)
    }

    private func handleInput(index: Int, newVal: String) {
        // Keep only last character typed
        let filtered = newVal.filter { $0.isNumber }
        if filtered.count > 1 {
            digits[index] = String(filtered.suffix(1))
        } else {
            digits[index] = filtered
        }
        // Advance focus
        if !digits[index].isEmpty && index < 5 {
            focusedIndex = index + 1
        } else if digits[index].isEmpty && index > 0 {
            focusedIndex = index - 1
        }
    }
}

#Preview {
    CodeVerificationView(
        email: "test@example.com",
        onSuccess: { _ in },
        dismiss: {},
        viewModel: AuthViewModel(
            authRepository: AuthRepository(
                client: NetworkClient(),
                authPreferences: AuthPreferences(),
                appPreferences: AppPreferences()
            ),
            appPreferences: AppPreferences()
        )
    )
}
