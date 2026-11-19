// ScreenRegisterView.swift
// Replaces ui/screens/register/ScreenRegister.kt
// 3-step wizard: email → dados pessoais → código de verificação

import SwiftUI

struct ScreenRegisterView: View {

    var navigate: (AppRoute) -> Void
    var dismiss: () -> Void

    @ObservedObject var viewModel: AuthViewModel

    @State private var step = 1
    private let totalSteps = 3

    // Step 1
    @State private var email = ""
    // Step 2
    @State private var userName = ""
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker = false
    // Step 3
    @State private var digits = Array(repeating: "", count: 6)
    @FocusState private var focusedDigit: Int?

    @State private var alertMessage = ""
    @State private var showAlert = false

    private var emailValid: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private var progress: Double { Double(step) / Double(totalSteps) }

    private var allFilled: Bool { digits.allSatisfy { !$0.isEmpty } }
    private var fullCode: String { digits.joined() }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }

    private var isoDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header: back + progress
                HStack {
                    Button { goBack() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    ProgressView(value: progress)
                        .tint(Color.brandOrange)
                        .padding(.horizontal, 16)

                    Spacer().frame(width: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // Step content
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        switch step {
                        case 1: stepEmailView
                        case 2: stepDadosView
                        case 3: stepCodigoView
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }

                Spacer()
            }

            // Bottom navigation bar
            bottomBar
        }
        .navigationBarHidden(true)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate, isPresented: $showDatePicker)
        }
    }

    // MARK: - Step 1: Email

    private var stepEmailView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Entre no Feijão no Prato")
                .font(.system(size: 20, weight: .bold))

            Spacer().frame(height: 8)

            Text("Informe o e-mail de acesso")
                .font(.system(size: 18))

            HStack {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                if emailValid {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(red: 0.298, green: 0.686, blue: 0.314))
                }
            }
            .padding(12)
            .background(Color(white: 0.973))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(emailValid ? Color.brandOrange : Color(white: 0.8), lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }

    // MARK: - Step 2: Personal data

    private var stepDadosView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quais são os seus dados?")
                .font(.system(size: 20, weight: .bold))

            VStack(alignment: .leading, spacing: 4) {
                Text("Como prefere que a gente chame você?")
                    .font(.system(size: 16))
                TextField("Nome", text: $userName)
                    .padding(12)
                    .background(Color(white: 0.973))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(white: 0.8), lineWidth: 1)
                    )
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Data de Nascimento")
                    .font(.system(size: 16))

                Button { showDatePicker = true } label: {
                    HStack {
                        Text(selectedDate.map { dateFormatter.string(from: $0) } ?? "Selecione sua data")
                            .foregroundColor(selectedDate == nil ? Color(white: 0.6) : .black)
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(Color.brandOrange)
                    }
                    .padding(12)
                    .background(Color(white: 0.973))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(white: 0.8), lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Step 3: OTP code

    private var stepCodigoView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Você recebeu um código por e-mail.")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.secondary)

            Text("Enviamos o código de verificação para o seu e-mail. Verifique seu e-mail e insira o código abaixo:")
                .font(.system(size: 18))
                .foregroundColor(Color(white: 0.4))

            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { i in
                    TextField("", text: $digits[i])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 48, height: 56)
                        .background(Color(white: 0.973))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedDigit == i ? Color.brandOrange : Color(white: 0.8), lineWidth: 1)
                        )
                        .cornerRadius(8)
                        .focused($focusedDigit, equals: i)
                        .onChange(of: digits[i]) { newVal in
                            let f = newVal.filter { $0.isNumber }
                            digits[i] = f.isEmpty ? "" : String(f.suffix(1))
                            if !digits[i].isEmpty, i < 5 { focusedDigit = i + 1 }
                        }
                }
            }
            .onAppear { focusedDigit = 0 }

            Button {
                // reenviar not implemented in original either
            } label: {
                Text("REENVIAR CÓDIGO")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.827, green: 0.42, blue: 0.302))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color(red: 0.827, green: 0.42, blue: 0.302), lineWidth: 1)
                    )
            }

            Button {
                guard allFilled else { return }
                Task {
                    let success = await viewModel.login(email: email, code: fullCode)
                    if success {
                        navigate(.introduction1(screen: 1))
                    } else {
                        alertMessage = "Erro ao fazer login."
                        showAlert = true
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
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(allFilled ? Color.brandOrange : Color(white: 0.8))
                .clipShape(Capsule())
            }
            .disabled(!allFilled || viewModel.isLoading)
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack {
            Spacer().frame(width: 48)
            Spacer()
            if step < totalSteps {
                Button { advanceStep() } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(canAdvance ? Color.brandOrange : Color(white: 0.8))
                }
                .disabled(!canAdvance || viewModel.isLoading)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.92))
    }

    private var canAdvance: Bool {
        switch step {
        case 1: return emailValid
        case 2: return !userName.isEmpty && selectedDate != nil
        default: return false
        }
    }

    // MARK: - Navigation helpers

    private func goBack() {
        if step > 1 { step -= 1 } else { dismiss() }
    }

    private func advanceStep() {
        switch step {
        case 1:
            step = 2
        case 2:
            Task {
                guard let date = selectedDate else { return }
                let datePerfil = dateFormatter.string(from: date)
                let isoDate = isoDateFormatter.string(from: date)

                let result = await viewModel.registerRespondente(
                    nome: userName,
                    email: email,
                    nascimento: isoDate,
                    dataNascimentoPerfil: datePerfil
                )
                switch result {
                case .success, .emailAlreadyExists:
                    let sent = await viewModel.requestAccessCode(email: email)
                    if sent {
                        step = 3
                    } else {
                        alertMessage = "Cadastro realizado, mas não foi possível enviar o código."
                        showAlert = true
                    }
                case .unknownError:
                    alertMessage = "Usuário já cadastrado."
                    showAlert = true
                }
            }
        default:
            break
        }
    }
}

// MARK: - Date picker sheet

private struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    @Binding var isPresented: Bool
    @State private var tempDate = Date()

    var body: some View {
        NavigationStack {
            DatePicker("", selection: $tempDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .navigationTitle("Data de Nascimento")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("OK") {
                            selectedDate = tempDate
                            isPresented = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { isPresented = false }
                    }
                }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ScreenRegisterView(
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
