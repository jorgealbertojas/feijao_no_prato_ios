// IaFoodViewModel.swift
// Ports ui/screens/iaFood/PhotoViewModel.kt — shared state for the AI Food flow

import Foundation
import UIKit

// MARK: - Domain model

struct HistoricoImagemIA: Identifiable {
    let id = UUID()
    let refeicao: String
    let resposta: String
    let data: Date

    var formattedData: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yy 'às' HH:mm"
        return f.string(from: data)
    }

    var icon: String {
        let lower = refeicao.lowercased()
        if lower.contains("caf") { return "cup.and.saucer.fill" }
        if lower.contains("alm") { return "fork.knife" }
        return "moon.fill"
    }
}

enum AnalysisState: Equatable {
    case idle
    case analyzing
    case success(String)
    case error(String)
}

private let errorMsg = "Ops, algo deu errado na análise do seu prato. Poderia enviar a imagem de novo? Obrigada!"

@MainActor
final class IaFoodViewModel: ObservableObject {

    // MARK: - Shared state across AI Food screens

    @Published var selectedImage: UIImage? = nil
    @Published var selectedMeal: String = "Café da Manhã"
    @Published var meatSubstitute: String? = nil
    @Published var analysisState: AnalysisState = .idle
    @Published var iaQuantity: Int = 0
    @Published var historicoIA: [HistoricoImagemIA] = []

    private let prefs = AppPreferences()
    private let authPrefs = AuthPreferences()

    // MARK: - Init

    init() {
        iaQuantity = prefs.iaQuantity
    }

    // MARK: - Meal selection

    var pedeSubstitutoDeCarne: Bool { selectedMeal != "Café da Manhã" }

    func updateSelectedMeal(_ meal: String) {
        selectedMeal = meal
        if !pedeSubstitutoDeCarne { meatSubstitute = nil }
    }

    func updateMeatSubstitute(_ value: String) {
        meatSubstitute = value
    }

    var canSend: Bool {
        selectedImage != nil && (pedeSubstitutoDeCarne ? meatSubstitute != nil : true)
    }

    // MARK: - Image management

    func setSelectedImage(_ image: UIImage) {
        selectedImage = image
        analysisState = .idle
    }

    func clearSelectedImage() {
        selectedImage = nil
        meatSubstitute = nil
        analysisState = .idle
    }

    // MARK: - API analysis

    func analyzeSelectedImage() async {
        guard case .idle = analysisState else { return }
        guard let image = selectedImage else { return }

        guard let imageBase64 = imageToBase64(image) else {
            analysisState = .error(errorMsg)
            return
        }

        analysisState = .analyzing

        let tipoRefeicao: Int
        switch selectedMeal {
        case "Café da Manhã": tipoRefeicao = 0
        case "Almoço": tipoRefeicao = 1
        default: tipoRefeicao = 2
        }

        let body = ProcessarImagemRequest(
            substituiuCarne: meatSubstitute == "Sim",
            tipoRefeicao: tipoRefeicao,
            imageBase64: imageBase64
        )

        do {
            let result = try await postAnalysis(body)
            if result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                analysisState = .error(errorMsg)
            } else {
                analysisState = .success(result)
                consumeIACredit()
                historicoIA.insert(
                    HistoricoImagemIA(refeicao: selectedMeal, resposta: result, data: Date()),
                    at: 0
                )
            }
        } catch {
            analysisState = .error(errorMsg)
        }
    }

    // MARK: - Credits

    func reloadIAQuantity() {
        iaQuantity = prefs.iaQuantity
    }

    private func consumeIACredit() {
        guard prefs.iaQuantity > 0 else { return }
        prefs.iaQuantity -= 1
        iaQuantity = prefs.iaQuantity
        prefs.totalCamera += 1
    }

    // MARK: - Helpers

    private func imageToBase64(_ image: UIImage) -> String? {
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaled = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let data = scaled?.jpegData(compressionQuality: 0.8) else { return nil }
        return data.base64EncodedString()
    }

    private func postAnalysis(_ body: ProcessarImagemRequest) async throws -> String {
        guard let url = URL(string: NetworkClient.baseURLString + "api/zIA/processarIA") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authPrefs.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: config)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        // Response is a plain string (not JSON-wrapped)
        if let text = String(data: data, encoding: .utf8) {
            return text.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
        throw URLError(.cannotDecodeContentData)
    }
}

// MARK: - Request model

struct ProcessarImagemRequest: Codable {
    let substituiuCarne: Bool
    let tipoRefeicao: Int
    let imageBase64: String
}
