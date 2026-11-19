// EmailInputView.swift
// Replaces ui/screens/login/EmailInputScreen.kt

import SwiftUI

struct EmailInputView: View {

    var navigate: (AppRoute) -> Void
    var dismiss: () -> Void

    @ObservedObject var viewModel: AuthViewModel

    @State private var email = ""
    @State private var showError = false

    private var isValid: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Back button
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(24)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Entre no Feijão no Prato")
                        .font(.system(size: 20, weight: .bold))

                    Spacer().frame(height: 16)

                    Text("Informe o e-mail de acesso")
                        .font(.system(size: 18))

                    Spacer().frame(height: 4)

                    HStack {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)

                        if isValid {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(red: 0.298, green: 0.686, blue: 0.314))
                        }
                    }
                    .padding(12)
                    .background(Color(white: 0.973))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isValid ? Color.brandOrange : Color(white: 0.8), lineWidth: 1)
                    )
                    .cornerRadius(8)

                    if showError {
                        Text("Código incorreto. Tente novamente.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }

            // Confirm button pinned to bottom
            Button {
                Task {
                    let ok = await viewModel.requestAccessCode(email: email)
                    if ok {
                        navigate(.verify(email: email))
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
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isValid ? Color.brandOrange : Color(white: 0.8))
                .cornerRadius(8)
            }
            .disabled(!isValid || viewModel.isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    EmailInputView(
        navigate: { _ in },
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
