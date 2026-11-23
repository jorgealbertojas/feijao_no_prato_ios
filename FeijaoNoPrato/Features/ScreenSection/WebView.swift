// WebView.swift
// Ports ui/screens/screenSection/WebViewScreen.kt

import SwiftUI
import SafariServices

// MARK: - SFSafariViewController wrapper

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Public SwiftUI view

struct WebViewScreen: View {

    let url: String

    var body: some View {
        if let parsed = URL(string: url) {
            SafariView(url: parsed)
                .ignoresSafeArea()
        } else {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                Text("URL inválida")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
