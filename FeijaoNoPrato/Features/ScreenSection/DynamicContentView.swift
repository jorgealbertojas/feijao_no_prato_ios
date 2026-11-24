// DynamicContentView.swift
// Ports DynamicPaginas.kt — renders SectionItem list by tipo

import SwiftUI

struct DynamicContentView: View {

    let items: [SectionItem]
    let imageBaseURL: String
    let selectedOption: String?
    let onOptionSelected: (String) -> Void
    let navigate: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                itemView(item)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func itemView(_ item: SectionItem) -> some View {
        let isCentered = item.alinhamento == "Centro"
        let align: TextAlignment = isCentered ? .center : .leading

        switch item.tipo ?? "" {

        case "Titulo":
            Text(item.texto ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(align)
                .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
                .padding(.vertical, 4)

        case "SubTitulo":
            Text(item.texto ?? "")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(align)
                .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
                .padding(.vertical, 4)

        case "Conteudo":
            ConteudoText(texto: item.texto ?? "", isCentered: isCentered)

        case "Etiqueta":
            ChipRow(text: item.texto ?? "")

        case "Espacamento":
            let size = CGFloat(item.tamanho ?? 8)
            Spacer().frame(height: size)

        case "Imagem":
            if let name = item.nomeArquivo, !name.isEmpty {
                let imageURL = URL(string: imageBaseURL + name)
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    case .failure:
                        Color(.systemGray5)
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .cornerRadius(8)
                    default:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 120)
                    }
                }
                .padding(.vertical, 8)
            }

        case "GrupoImagens":
            if let imgs = item.imagens, !imgs.isEmpty {
                let isHorizontal = item.direcao == "Horizontal"
                if isHorizontal {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(imgs.enumerated()), id: \.offset) { _, img in
                                imageCell(img.nomeArquivo)
                                    .frame(width: 160, height: 120)
                            }
                        }
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(Array(imgs.enumerated()), id: \.offset) { _, img in
                            imageCell(img.nomeArquivo)
                                .frame(height: 120)
                        }
                    }
                }
            }

        case "QuadroDestaque":
            DestaqueCard(modelo: item.modelo, texto: item.texto ?? "", isCentered: isCentered)

        case "Carrossel":
            if let subitems = item.itens, !subitems.isEmpty {
                CarrosselView(items: subitems, imageBaseURL: imageBaseURL)
            }

        case "VideoYoutube":
            if let url = item.url, !url.isEmpty {
                YoutubePreviewButton(videoID: url)
            }

        case "Pergunta":
            if let opcoes = item.opcoes, !opcoes.isEmpty {
                PerguntaView(
                    opcoes: opcoes,
                    selectedOption: selectedOption,
                    onSelect: onOptionSelected
                )
            }

        case "LinkExterno":
            if let url = item.url ?? item.personalizacao, !url.isEmpty {
                ContinueButton(label: item.personalizacao ?? "ACESSAR") {
                    navigate(.webView(url: url))
                }
            }

        case "BotaoExtra":
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

// MARK: - DestaqueCard (matches Android: yellow border, no icon, bold text)

private struct DestaqueCard: View {
    let modelo: String?
    let texto: String
    let isCentered: Bool

    // Android QuadroDestaque uses a warm golden border — matches secondary/warning yellow
    private let borderColor = Color(red: 0.780, green: 0.639, blue: 0.212) // ~#C7A336

    private var parsedText: AttributedString {
        (try? AttributedString(
            markdown: preprocessForMarkdown(texto),
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(texto)
    }

    var body: some View {
        Text(parsedText)
            .font(.system(size: 15, weight: .bold))
            .multilineTextAlignment(isCentered ? .center : .leading)
            .foregroundColor(Color(.label))
            .frame(maxWidth: .infinity, alignment: isCentered ? .center : .leading)
            .padding(14)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 2)
            )
            .padding(.vertical, 4)
    }
}

// MARK: - CarrosselView

private struct CarrosselView: View {
    let items: [SectionItem]
    let imageBaseURL: String

    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                VStack(spacing: 8) {
                    if let name = item.nomeArquivo, !name.isEmpty {
                        let url = URL(string: imageBaseURL + name)
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img): img.resizable().scaledToFit()
                            default: Color(.systemGray5)
                            }
                        }
                        .frame(height: 180)
                        .cornerRadius(8)
                    }
                    if let texto = item.texto, !texto.isEmpty {
                        Text(texto)
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                }
                .tag(idx)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 240)
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
                Button {
                    onSelect(label)
                } label: {
                    Text(label)
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
