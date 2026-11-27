// DynamicContentView.swift
// Ports DynamicPaginas.kt — renders SectionItem list by tipo

import SwiftUI
import WebKit

struct DynamicContentView: View {

    let items: [SectionItem]
    let imageBaseURL: String
    let selectedOption: String?
    let tempCorrectCount: Int
    let onOptionSelected: (String) -> Void
    let navigate: (AppRoute) -> Void
    var onBotaoExtra: ((String) -> Void)?

    // Android: parsePersonalizacao — extracts all numbers from personalizacao string
    private func parsePersonalizacao(_ personalizacao: String?) -> Set<Int> {
        guard let p = personalizacao, !p.isEmpty else { return [] }
        let nums = p.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        return Set(nums)
    }

    // Android: replaceXPlaceholder — replaces {{x}} or standalone "x" with the count
    private func replaceXPlaceholder(_ text: String, count: Int) -> String {
        var t = text.replacingOccurrences(of: "{{x}}", with: "\(count)")
        t = t.replacingOccurrences(of: "\\bx\\b",
                                   with: "\(count)",
                                   options: .regularExpression)
        return t
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                // Carrossel and GrupoImagens horizontal span full width — no horizontal padding
                if isFullWidthItem(item) {
                    itemView(item)
                } else {
                    itemView(item)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func isFullWidthItem(_ item: SectionItem) -> Bool {
        let tipo = item.tipo?.lowercased() ?? ""
        if tipo == "carrossel" { return true }
        return tipo == "grupoimagens" &&
               item.direcao?.caseInsensitiveCompare("Horizontal") == .orderedSame
    }

    @ViewBuilder
    private func itemView(_ item: SectionItem) -> some View {
        let isCentered = item.alinhamento == "Centro"
        let align: TextAlignment = isCentered ? .center : .leading

        switch item.tipo?.lowercased() ?? "" {

        case "titulo":
            // Android: only show if personalizacao numbers contain tempCorrectCount (or no filter)
            let tituloNums = parsePersonalizacao(item.personalizacao)
            if tituloNums.isEmpty || tituloNums.contains(tempCorrectCount) {
                let rawText = item.texto ?? ""
                let displayText = replaceXPlaceholder(rawText, count: tempCorrectCount)
                Text(displayText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(align)
                    .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
                    .padding(.vertical, 4)
            }

        case "subtitulo":
            let subAttr = (try? AttributedString(
                markdown: preprocessForMarkdown(item.texto ?? ""),
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )) ?? AttributedString(item.texto ?? "")
            Text(subAttr)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(align)
                .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
                .padding(.vertical, 4)

        case "conteudo":
            ConteudoText(texto: item.texto ?? "", isCentered: isCentered)

        case "etiqueta":
            ChipRow(text: item.texto ?? "", isCentered: item.alinhamento == "Centro")

        case "espacamento":
            let size = CGFloat(item.tamanho ?? 8)
            Spacer().frame(height: size)

        case "imagem":
            // Android: only show if personalizacao numbers contain tempCorrectCount (or no filter)
            let imagemNums = parsePersonalizacao(item.personalizacao)
            let shouldShow = imagemNums.isEmpty || imagemNums.contains(tempCorrectCount)
            let imgName = item.nomeArquivo ?? item.url ?? ""
            if shouldShow && !imgName.isEmpty {
                // The API sometimes returns partially-encoded filenames (e.g. %2C for comma but
                // literal spaces). Decode first then re-encode so the URL is valid for Azure Blob.
                let decoded = imgName.removingPercentEncoding ?? imgName
                let encoded = decoded.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? decoded
                let fullURL = imgName.hasPrefix("http") ? imgName : imageBaseURL + encoded
                if let imageURL = URL(string: fullURL) {
                    // Android: sizeNumber = (tamanho ?? 100) * 3
                    // sizeNumber == 300 → fillMaxWidth(); else → fixed width in dp
                    let sizeNumber = Int((item.tamanho ?? 100) * 3)
                    let isFullWidth = sizeNumber == 300
                    let imageWidth = CGFloat(sizeNumber)

                    if isFullWidth {
                        // Android: fillMaxWidth() + wrapContentHeight() + ContentScale.FillWidth
                        // SelfSizingWebImageView loads via WKWebView (reliable for Azure Blob URLs)
                        // and auto-sizes height to the image's natural aspect ratio via JS scrollHeight.
                        let contentWidth = UIScreen.main.bounds.width - 32
                        SelfSizingWebImageView(url: imageURL, width: contentWidth)
                            .cornerRadius(12)
                            .padding(.vertical, 8)
                    } else {
                        let rowAlignment: HorizontalAlignment = {
                            switch item.alinhamento {
                            case "Esquerda": return .leading
                            case "Direita": return .trailing
                            default: return .center
                            }
                        }()
                        HStack {
                            if rowAlignment == .center || rowAlignment == .trailing { Spacer() }
                            // Use SelfSizingWebImageView so height matches the image's natural aspect
                            // ratio — same as Android which only sets width and lets height wrap.
                            SelfSizingWebImageView(url: imageURL, width: imageWidth)
                                .cornerRadius(12)
                            if rowAlignment == .center || rowAlignment == .leading { Spacer() }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }

        case "grupoimagens":
            if let imgs = item.imagens, !imgs.isEmpty {
                let isHorizontal = item.direcao?.caseInsensitiveCompare("Horizontal") == .orderedSame
                if isHorizontal {
                    HorizontalImageCarousel(images: imgs, imageBaseURL: imageBaseURL)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(Array(imgs.enumerated()), id: \.offset) { _, img in
                            imageCell(img.nomeArquivo)
                                .frame(height: 120)
                        }
                    }
                }
            }

        case "quadrodestaque":
            DestaqueCard(modelo: item.modelo, texto: item.texto ?? "", isCentered: isCentered)

        case "carrossel":
            if let subitems = item.itens, !subitems.isEmpty {
                CarrosselView(items: subitems, imageBaseURL: imageBaseURL)
            }

        case "videoyoutube":
            if let url = item.url, !url.isEmpty {
                YoutubePreviewButton(videoID: url)
            }

        case "pergunta":
            if item.personalizacao == "[SELECT_SLIDER_NUMBER]" {
                ReadinessToChangesSlider(onReady: onOptionSelected)
            } else if item.personalizacao == "[SELECT_SLIDER_NUMBER_QUEST]" {
                ReadinessToChangesSliderQuest(onReady: onOptionSelected)
            } else if item.personalizacao == "[SELECT_DOUBLE]" {
                SelectPairsMatchView(
                    descricaOopcaoCorreta: item.descricaOopcaoCorreta ?? "",
                    onOptionSelected: onOptionSelected
                )
            } else if item.personalizacao == "[SELECT_MULT]", let opcoes = item.opcoes, !opcoes.isEmpty {
                NutritionTipCardSelect(
                    prefixo: item.descricao ?? item.texto ?? "",
                    opcoes: opcoes,
                    onSelectionChanged: onOptionSelected
                )
            } else if let opcoes = item.opcoes, !opcoes.isEmpty {
                PerguntaView(
                    opcoes: opcoes,
                    selectedOption: selectedOption,
                    onSelect: onOptionSelected
                )
            }

        case "linkexterno":
            if let url = item.url ?? item.personalizacao, !url.isEmpty {
                ContinueButton(label: item.personalizacao ?? "ACESSAR") {
                    navigate(.webView(url: url))
                }
            }

        case "botaoextra":
            let personalizacao = item.personalizacao ?? ""
            let label = (item.descricao ?? item.texto ?? "").uppercased()
            if !personalizacao.isEmpty && !label.isEmpty {
                BotaoExtraView(label: label, personalizacao: personalizacao) {
                    onBotaoExtra?(personalizacao)
                }
            }

        default:
            if let texto = item.texto, !texto.isEmpty {
                Text(texto)
                    .font(.system(size: 16))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(.vertical, 4)
            }
        }
    }

    private func imageCell(_ name: String?) -> some View {
        let url = name.map { URL(string: imageBaseURL + $0) } ?? nil
        return AsyncImage(url: url) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFill()
            default:
                Color(.systemGray5)
            }
        }
        .clipped()
        .cornerRadius(6)
    }
}

// MARK: - SelectPairsMatchView
// Ports SelectPairsMatchItem.kt — two-column matching pairs quiz.
// descricaOopcaoCorreta format: "[item1/group1][item2/group2]..."
// Left column: items in order. Right column: groups shuffled.
// Tap one from each side to match; green = correct (then disabled), red = wrong (retry).

private enum PairChipState { case normal, selected, correct, wrong, disabled }

private struct PairChipItem: Identifiable {
    let id: Int
    let text: String
    let correctMatchId: Int
    var state: PairChipState
}

private struct SelectPairsMatchView: View {
    let descricaOopcaoCorreta: String
    let onOptionSelected: (String) -> Void

    @State private var leftItems: [PairChipItem] = []
    @State private var rightItems: [PairChipItem] = []
    @State private var selectedLeftId: Int? = nil
    @State private var selectedRightId: Int? = nil
    @State private var matchedTokens: [String] = []

    private func parsePairs() -> [(left: String, right: String)] {
        guard !descricaOopcaoCorreta.isEmpty,
              let regex = try? NSRegularExpression(pattern: #"\[([^\]]+)\]"#) else { return [] }
        let str = descricaOopcaoCorreta
        let range = NSRange(str.startIndex..., in: str)
        return regex.matches(in: str, range: range).compactMap { match in
            guard let r = Range(match.range(at: 1), in: str) else { return nil }
            let parts = String(str[r]).split(separator: "/", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { return nil }
            return (left: parts[0], right: parts[1])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Toque nos pares")
                .font(.system(size: 16, weight: .semibold))
                .padding(.bottom, 4)

            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 10) {
                    ForEach(leftItems) { item in
                        PairChipView(item: item) { handleLeftTap(item) }
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 10) {
                    ForEach(rightItems) { item in
                        PairChipView(item: item) { handleRightTap(item) }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            let pairs = parsePairs()
            leftItems = pairs.enumerated().map { idx, p in
                PairChipItem(id: idx, text: p.left, correctMatchId: idx, state: .normal)
            }
            rightItems = pairs.enumerated().map { idx, p in
                PairChipItem(id: idx, text: p.right, correctMatchId: idx, state: .normal)
            }.shuffled()
        }
    }

    private func handleLeftTap(_ item: PairChipItem) {
        guard item.state != .disabled else { return }
        if selectedLeftId == item.id {
            updateLeft(item.id, .normal); selectedLeftId = nil; return
        }
        if let prev = selectedLeftId { updateLeft(prev, .normal) }
        selectedLeftId = item.id
        updateLeft(item.id, .selected)
        tryResolve()
    }

    private func handleRightTap(_ item: PairChipItem) {
        guard item.state != .disabled else { return }
        if selectedRightId == item.id {
            updateRight(item.id, .normal); selectedRightId = nil; return
        }
        if let prev = selectedRightId { updateRight(prev, .normal) }
        selectedRightId = item.id
        updateRight(item.id, .selected)
        tryResolve()
    }

    private func tryResolve() {
        guard let lId = selectedLeftId, let rId = selectedRightId,
              let left = leftItems.first(where: { $0.id == lId }),
              let right = rightItems.first(where: { $0.id == rId }) else { return }

        let isCorrect = left.correctMatchId == right.correctMatchId

        if isCorrect {
            updateLeft(lId, .correct)
            updateRight(rId, .correct)
            let token = "\(left.text)/\(right.text)"
            if !matchedTokens.contains(token) { matchedTokens.append(token) }
            let formatted = matchedTokens.map { "[\($0)]" }.joined()
            onOptionSelected(formatted)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                updateLeft(lId, .disabled)
                updateRight(rId, .disabled)
                selectedLeftId = nil
                selectedRightId = nil
            }
        } else {
            updateLeft(lId, .wrong)
            updateRight(rId, .wrong)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                updateLeft(lId, .normal)
                updateRight(rId, .normal)
                selectedLeftId = nil
                selectedRightId = nil
            }
        }
    }

    private func updateLeft(_ id: Int, _ state: PairChipState) {
        leftItems = leftItems.map { $0.id == id ? PairChipItem(id: $0.id, text: $0.text, correctMatchId: $0.correctMatchId, state: state) : $0 }
    }
    private func updateRight(_ id: Int, _ state: PairChipState) {
        rightItems = rightItems.map { $0.id == id ? PairChipItem(id: $0.id, text: $0.text, correctMatchId: $0.correctMatchId, state: state) : $0 }
    }
}

private struct PairChipView: View {
    let item: PairChipItem
    let onTap: () -> Void

    var body: some View {
        let (bg, border, alpha): (Color, Color, Double) = {
            switch item.state {
            case .normal:   return (.clear,                                   Color(white: 0.87), 1.0)
            case .selected: return (Color(red: 0.918, green: 0.949, blue: 1.0), Color(red: 0.608, green: 0.725, blue: 1.0), 1.0)
            case .correct:  return (Color(red: 0.867, green: 0.965, blue: 0.867), Color(red: 0.263, green: 0.627, blue: 0.278), 1.0)
            case .wrong:    return (Color(red: 1.0,   green: 0.882, blue: 0.882), Color(red: 0.898, green: 0.224, blue: 0.208), 1.0)
            case .disabled: return (.clear,                                   Color(white: 0.9),  0.45)
            }
        }()

        Button(action: onTap) {
            Text(item.text)
                .font(.system(size: 14))
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(bg)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .opacity(alpha)
        .disabled(item.state == .disabled)
    }
}

// MARK: - SelfSizingWebImageView
// Full-width image that auto-sizes its height to the image's natural aspect ratio.
// Uses WKWebView (which reliably loads Azure Blob Storage URLs) and injects CSS so
// the image fills the width; JS reads scrollHeight after load to set the SwiftUI frame.

private struct SelfSizingWebImageView: View {
    let url: URL
    let width: CGFloat
    @State private var height: CGFloat = 240

    var body: some View {
        _SelfSizingWebView(url: url, width: width, height: $height)
            .frame(width: width, height: height)
    }
}

private struct _SelfSizingWebView: UIViewRepresentable {
    let url: URL
    let width: CGFloat
    @Binding var height: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(heightBinding: $height) }

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "imageLoaded")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Load as HTML string so img.onload fires AFTER the image downloads and renders.
        // Direct URLRequest wrapping means didFinish fires before image loads → scrollHeight unreliable.
        let w = Int(width)
        let html = """
        <!DOCTYPE html>
        <html><head>
        <meta name="viewport" content="width=\(w),initial-scale=1,maximum-scale=1">
        <style>*{margin:0;padding:0;box-sizing:border-box;}body{background:transparent;}img{width:\(w)px;height:auto;display:block;}</style>
        </head><body>
        <img src="\(url.absoluteString)"
             onload="window.webkit.messageHandlers.imageLoaded.postMessage(this.offsetHeight)"
             onerror="window.webkit.messageHandlers.imageLoaded.postMessage(-1)">
        </body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "imageLoaded")
    }

    // Store Binding<CGFloat> as a plain var (not @Binding) to avoid NSObject init ambiguity.
    class Coordinator: NSObject, WKScriptMessageHandler {
        var heightBinding: Binding<CGFloat>
        init(heightBinding: Binding<CGFloat>) { self.heightBinding = heightBinding }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "imageLoaded" else { return }
            let h: Double
            if let d = message.body as? Double { h = d }
            else if let i = message.body as? Int { h = Double(i) }
            else { return }
            guard h > 20 else { return }
            DispatchQueue.main.async { self.heightBinding.wrappedValue = CGFloat(h) }
        }
    }
}

// MARK: - WebImageView
// Fixed-size WKWebView-based image renderer — handles SVG, PNG, JPG and any other format.
// AsyncImage silently fails on SVG; this view handles all formats uniformly.

private struct WebImageView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let css = "body{margin:0;padding:0;background:transparent;display:flex;align-items:center;justify-content:center;height:100vh;}img{max-width:100%;max-height:100%;object-fit:contain;}"
            let js = "var s=document.createElement('style');s.textContent=`\(css)`;document.head.appendChild(s);"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}

// MARK: - ChipRow
// Ports ChipRowFromString.kt: outlined pill, transparent bg, neutral_400 border + text, uppercase.
// Delimiter is "|" (Android); centered when isCentered matches alinhamento=="Centro".

private struct ChipRow: View {
    let text: String
    let isCentered: Bool

    // Android neutral_400 — mid-gray used for chip border and text
    private static let neutral400 = Color(red: 0.55, green: 0.55, blue: 0.55)

    private var chips: [String] {
        text.components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        if isCentered {
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { ChipLabel(text: $0) }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chips, id: \.self) { ChipLabel(text: $0) }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct ChipLabel: View {
    let text: String
    private let neutral400 = Color(red: 0.55, green: 0.55, blue: 0.55)

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(neutral400)
            .padding(.top, 3)
            .padding(.horizontal, 8)
            .padding(.bottom, 2)
            .background(Color.clear)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(neutral400, lineWidth: 1))
    }
}

// MARK: - BotaoExtraView
// Ports Android DynamicPaginas.kt BotaoExtra branch:
//   [NEXT_SECTION] → ContinueButton1 (filled orange, full width, 60dp)
//   [OPEN_MENU] / [OPEN_FEIRA...] → ContinueButton2 (orange text, no bg)

private struct BotaoExtraView: View {
    let label: String
    let personalizacao: String
    let action: () -> Void

    // Android Color(0xFFD16D52)
    private let continueButton2Color = Color(red: 0.820, green: 0.427, blue: 0.322)

    var body: some View {
        if personalizacao == "[NEXT_SECTION]" {
            Button(action: action) {
                Text(label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.brandOrange)
                    .cornerRadius(50)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
        } else {
            Button(action: action) {
                Text(label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(continueButton2Color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
    }
}

// Android uses *text* (single asterisk) for bold and #text# for italic.
// Convert to SwiftUI markdown format (**text** = bold, *text* = italic).
private func preprocessForMarkdown(_ text: String) -> String {
    var out = ""
    var i = text.startIndex
    while i < text.endIndex {
        let c = text[i]
        let next = text.index(after: i)
        if c == "*" {
            if next < text.endIndex && text[next] == "*" {
                out += "**"
                i = text.index(after: next)
            } else {
                out += "**"
                i = next
            }
        } else if c == "#" {
            out += "*"
            i = next
        } else {
            out.append(c)
            i = next
        }
    }
    return out
}

// MARK: - ConteudoText (renders *bold* Android inline markers as bold)

private struct ConteudoText: View {
    let texto: String
    let isCentered: Bool

    var body: some View {
        let attrStr = (try? AttributedString(
            markdown: preprocessForMarkdown(texto),
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(texto)

        Text(attrStr)
            .font(.system(size: 17))
            .foregroundColor(Color(.label))
            .multilineTextAlignment(isCentered ? .center : .leading)
            .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
            .padding(.vertical, 4)
            .lineSpacing(4)
    }
}

// MARK: - DestaqueCard
// Android DestaqueCard.kt: modelo drives icon + color scheme.
// "Interrogacao" → green (EFF6E9 bg, 88A64E icon, questionmark)
// "Exclamacao"   → red   (FFEBEE bg, D32F2F icon, exclamationmark.triangle)
// "Informacao"   → gray  (F5F5F5 bg, 6D6D6D icon, info)
// nil/other      → NutritionTipCard style (yellow_200 border, 10% bg, no icon)

private struct DestaqueCard: View {
    let modelo: String?
    let texto: String
    let isCentered: Bool

    private struct Style {
        let bgColor: Color
        let iconColor: Color
        let iconName: String?
    }

    // Android yellow_200 = #dfb400
    private let yellow200 = Color(red: 0.875, green: 0.706, blue: 0.0)

    private var style: Style? {
        switch modelo {
        case "Interrogacao":
            return Style(bgColor: Color(red: 0.937, green: 0.965, blue: 0.914),
                         iconColor: Color(red: 0.533, green: 0.651, blue: 0.306),
                         iconName: "questionmark.circle.fill")
        case "Exclamacao":
            return Style(bgColor: Color(red: 1.0, green: 0.922, blue: 0.933),
                         iconColor: Color(red: 0.827, green: 0.184, blue: 0.184),
                         iconName: "exclamationmark.triangle.fill")
        case "Informacao":
            return Style(bgColor: Color(red: 0.961, green: 0.961, blue: 0.961),
                         iconColor: Color(red: 0.427, green: 0.427, blue: 0.427),
                         iconName: "info.circle.fill")
        default:
            return nil
        }
    }

    private var parsedText: AttributedString {
        (try? AttributedString(
            markdown: preprocessForMarkdown(texto),
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(texto)
    }

    var body: some View {
        if let s = style {
            HStack(alignment: .center, spacing: 12) {
                if let iconName = s.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(s.iconColor)
                }
                Text(parsedText)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .multilineTextAlignment(isCentered ? .center : .leading)
                    .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
                    .lineSpacing(4)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(s.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.vertical, 4)
        } else {
            // Default: NutritionTipCard yellow style
            Text(parsedText)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .multilineTextAlignment(isCentered ? .center : .leading)
                .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
                .padding(16)
                .background(yellow200.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(yellow200, lineWidth: 1)
                )
                .padding(.vertical, 16)
        }
    }
}

// MARK: - HorizontalImageCarousel (Android GrupoImagens direcao=="Horizontal")
// Swipeable card carousel: each card shows image (top) + caption (bottom).
// GeometryReader reads the actual container width at render time so the next card always peeks.
// Works for all GrupoImagens callers — modelo field is the caption text.

private struct HorizontalImageCarousel: View {
    let images: [SectionItemImage]
    let imageBaseURL: String

    var body: some View {
        let cardWidth = max(UIScreen.main.bounds.width * 0.72, 200)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(images.enumerated()), id: \.offset) { _, img in
                    ImageCarouselCard(image: img, imageBaseURL: imageBaseURL, cardWidth: cardWidth)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
        }
    }
}

private struct ImageCarouselCard: View {
    let image: SectionItemImage
    let imageBaseURL: String
    let cardWidth: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            let url = image.nomeArquivo.flatMap { URL(string: imageBaseURL + $0) }
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Color(.systemGray5)
                }
            }
            .frame(width: cardWidth, height: cardWidth * 0.65)
            .clipped()

            if let caption = image.modelo, !caption.isEmpty {
                Text(caption.replacingOccurrences(of: "\\n", with: "\n"))
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
        .frame(width: cardWidth)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
    }
}

// MARK: - CarrosselView
// Horizontal peekable carousel matching Android: 72% card width so next card peeks at right edge.
// Each SectionItem subitem has nomeArquivo (image) + texto (caption).

private struct CarrosselView: View {
    let items: [SectionItem]
    let imageBaseURL: String

    var body: some View {
        let cardWidth = max(UIScreen.main.bounds.width * 0.72, 200)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    CarrosselCard(item: item, imageBaseURL: imageBaseURL, cardWidth: cardWidth)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
        }
    }
}

private struct CarrosselCard: View {
    let item: SectionItem
    let imageBaseURL: String
    let cardWidth: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            if let name = item.nomeArquivo, !name.isEmpty {
                let url = URL(string: imageBaseURL + name)
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color(.systemGray5)
                    }
                }
                .frame(width: cardWidth, height: cardWidth * 0.65)
                .clipped()
            } else {
                Color(.systemGray5)
                    .frame(width: cardWidth, height: cardWidth * 0.65)
            }

            if let texto = item.texto, !texto.isEmpty {
                Text(texto.replacingOccurrences(of: "\\n", with: "\n"))
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
        }
        .frame(width: cardWidth)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
    }
}

// MARK: - YoutubePreviewButton
// Ports Android videoyoutube: loads YouTube thumbnail (hqdefault) with play button overlay.
// Tapping opens the video in YouTube app / browser.

private struct YoutubePreviewButton: View {
    let videoID: String

    private var thumbnailURL: URL? {
        // Try maxresdefault; falls back to hqdefault via AsyncImage phase
        URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
    }

    private var watchURL: URL? {
        // Opens YouTube app if installed, otherwise browser
        URL(string: "https://www.youtube.com/watch?v=\(videoID)")
    }

    var body: some View {
        Button {
            if let url = watchURL { UIApplication.shared.open(url) }
        } label: {
            ZStack {
                // Thumbnail image
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Color(.systemGray5)
                    default:
                        Color(.systemGray5).overlay(ProgressView())
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipped()

                // Play button overlay — matches Android ExoPlayer thumbnail style
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.55))
                        .frame(width: 56, height: 56)
                    Image(systemName: "play.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 2)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

// MARK: - PerguntaView
// Android selectOptionItem.kt: quaternary_11 (#F8F7F3) bg always; selected adds 2dp border in
// secondary_200 (#c64b4e) and colors the text secondary_200. Unselected = black text, no border.

struct PerguntaView: View {
    let opcoes: [SectionOption]
    let selectedOption: String?
    let onSelect: (String) -> Void

    // Android secondary_200 = #c64b4e
    private let selectedColor = Color(red: 0.776, green: 0.294, blue: 0.306)
    // Android quaternary_11 = #F8F7F3
    private let optionBg = Color(red: 0.973, green: 0.969, blue: 0.953)

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(opcoes.enumerated()), id: \.offset) { _, opcao in
                let label = opcao.descricao ?? ""
                let isSelected = selectedOption == label
                let attrLabel = (try? AttributedString(
                    markdown: preprocessForMarkdown(label),
                    options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
                )) ?? AttributedString(label)
                Button {
                    onSelect(label)
                } label: {
                    Text(attrLabel)
                        .font(.system(size: 17))
                        .foregroundColor(isSelected ? selectedColor : Color(.label))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(optionBg)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? selectedColor : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - NutritionTipCardSelect
// Ports NutritionTipCardSelect from Android: tipo=Pergunta + personalizacao=[SELECT_MULT].
// Shows ingredients as inline flowing tappable text inside a yellow_200 bordered card.
// Tapping toggles selection (orange highlight); onSelectionChanged reports comma-joined selections
// back to the ViewModel so CONFIRMAR can validate them.

private struct NutritionTipCardSelect: View {
    let prefixo: String
    let opcoes: [SectionOption]
    let onSelectionChanged: (String) -> Void

    // Single selection — tapping another deselects the previous
    @State private var selectedItem: String? = nil

    private let yellow200   = Color(red: 0.875, green: 0.706, blue: 0.0)
    // Android secondary_200 = #c64b4e (red text when selected)
    private let selectedRed = Color(red: 0.776, green: 0.294, blue: 0.306)

    private var ingredients: [String] {
        opcoes.compactMap { $0.descricao }.filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !prefixo.isEmpty {
                Text(prefixo + ":")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(.label))
            }

            IngredientFlow(
                items: ingredients,
                selectedItem: $selectedItem,
                selectedRed: selectedRed
            ) { item in
                selectedItem = item
                onSelectionChanged(item ?? "")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(yellow200.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(yellow200, lineWidth: 1.5))
        .padding(.vertical, 8)
    }
}

// MARK: - IngredientFlow
// Inline wrapping flow of ingredient tokens. Tapping selects (single); selected = red text only.

private struct IngredientFlow: View {
    let items: [String]
    @Binding var selectedItem: String?
    let selectedRed: Color
    let onTap: (String?) -> Void

    var body: some View {
        IngredientFlowLayout(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                let isSelected = selectedItem == item
                Button {
                    onTap(isSelected ? nil : item)
                } label: {
                    HStack(spacing: 0) {
                        Text(item)
                            .font(.system(size: 16))
                            .underline()
                            .foregroundColor(isSelected ? selectedRed : Color(.label))
                        if i < items.count - 1 {
                            Text("; ")
                                .font(.system(size: 16))
                                .foregroundColor(Color(.label))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// Custom Layout that wraps subviews like inline text
private struct IngredientFlowLayout: Layout {
    var spacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(subviews: subviews, in: proposal.replacingUnspecifiedDimensions().width).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let positions = layout(subviews: subviews, in: bounds.width).positions
        for (i, pos) in positions.enumerated() {
            subviews[i].place(
                at: CGPoint(x: pos.x + bounds.minX, y: pos.y + bounds.minY),
                proposal: .unspecified
            )
        }
    }

    private func layout(subviews: Subviews, in maxWidth: CGFloat) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowH: CGFloat = 0

        for subview in subviews {
            let sz = subview.sizeThatFits(.unspecified)
            if x + sz.width > maxWidth && x > 0 {
                x = 0
                y += rowH + spacing
                rowH = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += sz.width + spacing
            rowH = max(rowH, sz.height)
        }

        return (CGSize(width: maxWidth, height: y + rowH), positions)
    }
}

// MARK: - ReadinessToChangesSlider
// Ports ReadinessToChangeSlider.kt: [SELECT_SLIDER_NUMBER] pergunta type.
// Slider 0-10 with stage label pill, colored track, numbered ticks, and feedback text.
// Auto-enables CONFIRMAR on appear by calling onReady("slider_answered").

private struct ReadinessToChangesSlider: View {
    let onReady: (String) -> Void

    @State private var value: Double = 0

    private var stageIndex: Int { Int(value.rounded()) }

    private static let stages: [(text: String, color: Color)] = [
        ("NADA PRONTO",               Color(red: 0.984, green: 0.753, blue: 0.176)), // 0  #FBC02D
        ("NADA PRONTO",               Color(red: 0.984, green: 0.753, blue: 0.176)), // 1
        ("NADA PRONTO",               Color(red: 0.984, green: 0.753, blue: 0.176)), // 2
        ("COMEÇANDO A PENSAR",        Color(red: 0.961, green: 0.486, blue: 0.000)), // 3  #F57C00
        ("COMEÇANDO A PENSAR",        Color(red: 0.961, green: 0.486, blue: 0.000)), // 4
        ("ME PREPARANDO PARA MUDAR",  Color(red: 0.298, green: 0.686, blue: 0.314)), // 5  #4CAF50
        ("ME PREPARANDO PARA MUDAR",  Color(red: 0.298, green: 0.686, blue: 0.314)), // 6
        ("COMECEI A MUDAR",           Color(red: 0.012, green: 0.663, blue: 0.957)), // 7  #03A9F4
        ("COMECEI A MUDAR",           Color(red: 0.012, green: 0.663, blue: 0.957)), // 8
        ("MANTENDO MUDANÇAS",         Color(red: 0.098, green: 0.463, blue: 0.824)), // 9  #1976D2
        ("MANTENDO MUDANÇAS",         Color(red: 0.098, green: 0.463, blue: 0.824)), // 10
    ]

    private static let feedbacks = [
        "Mudar hábitos é MUITO difícil, mas nós sabemos como superar os obstáculos. Confia e vem com a gente.",
        "Mudar hábitos é MUITO difícil, mas nós sabemos como superar os obstáculos. Confia e vem com a gente.",
        "Mudar hábitos é MUITO difícil, mas nós sabemos como superar os obstáculos. Confia e vem com a gente.",
        "Pode se orgulhar por querer melhorar sua alimentação! Há desafios, mas nós conhecemos várias estratégias para superá-los. Continue, vamos te ajudar!",
        "Pode se orgulhar por querer melhorar sua alimentação! Há desafios, mas nós conhecemos várias estratégias para superá-los. Continue, vamos te ajudar!",
        "Você está bastante disposto, mas bate aquela insegurança, né? Não se preocupe! Sabemos os principais desafios deste momento e vamos te passar todas as dicas para superar!",
        "Você está bastante disposto, mas bate aquela insegurança, né? Não se preocupe! Sabemos os principais desafios deste momento e vamos te passar todas as dicas para superar!",
        "Uhuuul! Hora de colocar a alimentação saudável em prática! Vamos dar dicas para organizar a rotina, receitas para substituir ultraprocessados e mais. Simbora!",
        "Uhuuul! Hora de colocar a alimentação saudável em prática! Vamos dar dicas para organizar a rotina, receitas para substituir ultraprocessados e mais. Simbora!",
        "Que conquista! Agora é manter o equilíbrio e a constância no dia a dia.",
        "Que conquista! Agora é manter o equilíbrio e a constância no dia a dia.",
    ]

    private var stageColor: Color {
        Self.stages[min(stageIndex, 10)].color
    }
    private var stageText: String {
        Self.stages[min(stageIndex, 10)].text
    }
    private var feedbackText: String {
        Self.feedbacks[min(stageIndex, 10)]
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)

            // Stage pill
            Text(stageText)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(stageColor)
                .clipShape(Capsule())

            Spacer().frame(height: 16)

            // Slider — tint colors active track
            Slider(value: $value, in: 0...10, step: 1)
                .tint(stageColor)
                .padding(.horizontal, 4)

            // Number ticks 0-10
            HStack(spacing: 0) {
                ForEach(0...10, id: \.self) { n in
                    Text("\(n)")
                        .font(.system(size: 16, weight: n == stageIndex ? .bold : .regular))
                        .foregroundColor(n == stageIndex ? stageColor : Color(.systemGray3))
                        .frame(maxWidth: .infinity)
                }
            }

            Spacer().frame(height: 16)

            // Feedback message
            Text(feedbackText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(stageColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .onAppear {
            // Auto-enable CONFIRMAR: slider always counts as answered
            onReady("slider_answered")
        }
    }
}

// MARK: - ReadinessToChangesSliderQuest
// Ports ReadinessToChangeSliderQuest.kt: [SELECT_SLIDER_NUMBER_QUEST] — avaliação do módulo.
// Same layout as ReadinessToChangesSlider but with opinion labels and no feedback text.

private struct ReadinessToChangesSliderQuest: View {
    let onReady: (String) -> Void

    @State private var value: Double = 0

    private var stageIndex: Int { Int(value.rounded()) }

    private static let stages: [(text: String, color: Color)] = [
        ("Não gostei",   Color(red: 0.984, green: 0.753, blue: 0.176)), // 0  #FBC02D
        ("Não gostei",   Color(red: 0.984, green: 0.753, blue: 0.176)), // 1
        ("Não gostei",   Color(red: 0.984, green: 0.753, blue: 0.176)), // 2
        ("Gostei pouco", Color(red: 0.961, green: 0.486, blue: 0.000)), // 3  #F57C00
        ("Gostei pouco", Color(red: 0.961, green: 0.486, blue: 0.000)), // 4
        ("Indiferente",  Color(red: 0.298, green: 0.686, blue: 0.314)), // 5  #4CAF50
        ("Gostei",       Color(red: 0.012, green: 0.663, blue: 0.957)), // 6  #03A9F4
        ("Gostei",       Color(red: 0.012, green: 0.663, blue: 0.957)), // 7
        ("Gostei muito", Color(red: 0.098, green: 0.463, blue: 0.824)), // 8  #1976D2
        ("Gostei muito", Color(red: 0.098, green: 0.463, blue: 0.824)), // 9
        ("Gostei muito", Color(red: 0.098, green: 0.463, blue: 0.824)), // 10
    ]

    private var stageColor: Color { Self.stages[min(stageIndex, 10)].color }
    private var stageText: String  { Self.stages[min(stageIndex, 10)].text }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)

            // Stage pill
            Text(stageText)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(stageColor)
                .clipShape(Capsule())

            Spacer().frame(height: 16)

            // Slider
            Slider(value: $value, in: 0...10, step: 1)
                .tint(stageColor)
                .padding(.horizontal, 4)

            // Number ticks 0-10
            HStack(spacing: 0) {
                ForEach(0...10, id: \.self) { n in
                    Text("\(n)")
                        .font(.system(size: 16, weight: n == stageIndex ? .bold : .regular))
                        .foregroundColor(n == stageIndex ? stageColor : Color(.systemGray3))
                        .frame(maxWidth: .infinity)
                }
            }

            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 16)
        .onAppear { onReady("slider_answered") }
    }
}

// MARK: - ContinueButton

private struct ContinueButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.brandOrange)
                .cornerRadius(50)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}
