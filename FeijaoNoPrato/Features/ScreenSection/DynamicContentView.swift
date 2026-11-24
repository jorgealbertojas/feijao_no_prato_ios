// DynamicContentView.swift
// Ports DynamicPaginas.kt — renders SectionItem list by tipo

import SwiftUI
import WebKit

struct DynamicContentView: View {

    let items: [SectionItem]
    let imageBaseURL: String
    let selectedOption: String?
    let onOptionSelected: (String) -> Void
    let navigate: (AppRoute) -> Void

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
            Text(item.texto ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(align)
                .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
                .padding(.vertical, 4)

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
            ChipRow(text: item.texto ?? "")

        case "espacamento":
            let size = CGFloat(item.tamanho ?? 8)
            Spacer().frame(height: size)

        case "imagem":
            let imgName = item.nomeArquivo ?? item.url ?? item.personalizacao ?? ""
            if !imgName.isEmpty {
                // The API sometimes returns partially-encoded filenames (e.g. %2C for comma but
                // literal spaces). Decode first then re-encode so the URL is valid for Azure Blob.
                let decoded = imgName.removingPercentEncoding ?? imgName
                let encoded = decoded.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? decoded
                let fullURL = imgName.hasPrefix("http") ? imgName : imageBaseURL + encoded
                if let imageURL = URL(string: fullURL) {
                    WebImageView(url: imageURL)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.width)
                        .padding(.vertical, 8)
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
            if let opcoes = item.opcoes, !opcoes.isEmpty {
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
            // Rendered separately via bottom bar; skip inline rendering
            EmptyView()

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

// MARK: - WebImageView
// WKWebView-based image renderer — handles SVG, PNG, JPG and any other format.
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
            // Inject CSS to fit the image inside the view without scroll
            let css = """
            body{margin:0;padding:0;background:transparent;display:flex;align-items:center;justify-content:center;height:100vh;}
            img{max-width:100%;max-height:100%;object-fit:contain;}
            """
            let js = "var s=document.createElement('style');s.textContent=`\(css)`;document.head.appendChild(s);"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}

// MARK: - ChipRow

private struct ChipRow: View {
    let text: String
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(text.components(separatedBy: ","), id: \.self) { chip in
                    let trimmed = chip.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        Text(trimmed)
                            .font(.system(size: 12))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.brandOrange.opacity(0.12))
                            .foregroundColor(Color.brandOrange)
                            .clipShape(Capsule())
                    }
                }
            }
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

// MARK: - DestaqueCard (Android NutritionTipCard: yellow_200=#dfb400, 10% bg, 12dp radius, 18sp)

private struct DestaqueCard: View {
    let modelo: String?
    let texto: String
    let isCentered: Bool

    // Android yellow_200 = #dfb400
    private let yellow200 = Color(red: 0.875, green: 0.706, blue: 0.0)

    private var parsedText: AttributedString {
        (try? AttributedString(
            markdown: preprocessForMarkdown(texto),
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(texto)
    }

    var body: some View {
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

// MARK: - HorizontalImageCarousel (Android GrupoImagens direcao=="Horizontal")
// Swipeable card carousel: each card shows image (top) + caption (bottom).
// GeometryReader reads the actual container width at render time so the next card always peeks.
// Works for all GrupoImagens callers — modelo field is the caption text.

private struct HorizontalImageCarousel: View {
    let images: [SectionItemImage]
    let imageBaseURL: String

    var body: some View {
        GeometryReader { geo in
            // 72% of container so next card peeks ~22% at right edge, matching Android
            let cardWidth = max(geo.size.width * 0.72, 200)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(images.enumerated()), id: \.offset) { _, img in
                        ImageCarouselCard(image: img, imageBaseURL: imageBaseURL, cardWidth: cardWidth)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .padding(.vertical, 8)
            }
            .frame(width: geo.size.width)
        }
        // Fix GeometryReader height: image (72% * 65% of screen) + caption (~40pt) + padding (16pt)
        .frame(height: UIScreen.main.bounds.width * 0.72 * 0.65 + 56)
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
                Text(caption)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
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
        GeometryReader { geo in
            let cardWidth = max(geo.size.width * 0.72, 200)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        CarrosselCard(item: item, imageBaseURL: imageBaseURL, cardWidth: cardWidth)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
                .padding(.vertical, 8)
            }
            .frame(width: geo.size.width)
        }
        .frame(height: UIScreen.main.bounds.width * 0.72 * 0.65 + 56)
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
                Text(texto)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
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

private struct YoutubePreviewButton: View {
    let videoID: String

    var body: some View {
        Button {
            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.red)
                Text("Assistir no YouTube")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(.label))
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

// MARK: - PerguntaView

struct PerguntaView: View {
    let opcoes: [SectionOption]
    let selectedOption: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 10) {
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
                        .font(.system(size: 15))
                        .foregroundColor(isSelected ? .white : Color(.label))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(isSelected ? Color.brandOrange : Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.brandOrange : Color(.systemGray4), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
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
