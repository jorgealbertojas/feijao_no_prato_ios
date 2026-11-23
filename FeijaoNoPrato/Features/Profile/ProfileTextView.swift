// ProfileTextView.swift
// Replaces ui/screens/profile/ProfileTextScreen.kt + ProfileTexts.kt

import SwiftUI

// MARK: - Text content (mirrors ProfileTexts.kt)

enum ProfileTexts {
    static func text(for title: String) -> String {
        switch title {
        case "Sobre": return sobre
        case "Perguntas frequentes (FAQ)": return faq
        case "Termos e condições de uso": return termos
        case "Política de privacidade": return politicaPrivacidade
        default: return ""
        }
    }

    // MARK: Content strings

    static let sobre = """

O **Feijão no Prato** é um app de educação alimentar baseado no Guia Alimentar para a População Brasileira, documento oficial do Ministério da Saúde. Foi criado para te orientar como comer melhor considerando a rotina típica do brasileiro: corrida e com muitos obstáculos.

Aqui não tem terrorismo nutricional nem dieta da moda. Tem informação e respeito à cultura alimentar. O app te ajuda a montar um prato saudável valorizando alimentos simples, preparações caseiras e escolhas possíveis dentro da sua realidade.

Comer bem não é se limitar, é saber escolher, com consciência, o que é bom para sua saúde sem abrir mão do prazer.
"""

    static let faq = """
Como o app pode me ajudar a ter uma alimentação mais saudável?
Por meio de textos curtos, quizzes e reflexões sobre seu dia a dia, o app ajuda a reconhecer os tipos de alimentos, identificar produtos prejudiciais à saúde e como organizar sua rotina para montar pratos saudáveis e saborosos.

É necessário estar sempre conectado à internet para usar o app?
Sim, estar conectado garante que seu progresso seja salvo com segurança e mantenha os conteúdos e recursos atualizados - como atividades e recompensas. Assim, a experiência é mais completa e personalizada para você!

Quem criou o Feijão no Prato?
O Feijão no Prato foi criado por pesquisadoras do NUPENS (Núcleo de Pesquisas Epidemiológicas em Nutrição e Saúde), da Faculdade de Saúde Pública da USP.

**FUNCIONALIDADES**

Como funciona o "Percurso"?
Na tela inicial, você tem uma visão geral do percurso. Os feijões cinza indicam as seções que ainda não foram realizadas. Os amarelos mostram seções que você começou mas ainda não terminou, e os verdes as seções concluídas.

O que são os "Feijões" e como posso ganhá-los?
Os Feijões são as moedas desta jornada. Você ganha ao concluir desafios, acessar o app com regularidade e participar das atividades do Feijão no Prato.
Depois, você pode trocá-los por vídeos e conteúdos para aprimorar seu aprendizado na aba "Feira".
Vai te ajudar a engajar e valorizar cada passo da caminhada!

O que eu encontro na aba "Feira"?
A "Feira" é o espaço para ir além.
Lá você encontra conteúdos extras, curiosidades e dicas práticas para ampliar o que aprendeu sobre alimentação saudável.
Tudo ali é pensado para deixar sua alimentação mais prática e adaptada à sua realidade, sem deixar a saúde e o prazer de lado.
Desbloqueie tudo com os feijões que ganhará ao longo de sua jornada!

Onde posso ver meu progresso?
A aba Progresso mostra em que ponto da jornada você está e quantos feijões já conquistou. É uma forma simples de enxergar o quanto você já caminhou e valorizar cada avanço!
Nesta aba você também encontra quantos pratos você já avaliou com a IA no prato e a como está sua alimentação, de acordo com as respostas dos questionários realizados ao longo da jornada.

**USO DO APLICATIVO**

Quantas seções posso fazer por dia?
Você pode realizar o equivalente a 1 seção por dia, ou seja, até 2 atividades diárias.
Mesmo que você queira fazer mais, calma... Nossa ideia é manter um ritmo leve e constante, sem excesso de informação.
Um pouco por dia é suficiente para avançar com consistência!

"""

    static let termos = """
Última atualização: 04 de novembro de 2026

**1. ACEITAÇÃO E VINCULAÇÃO**

O presente Termo de Uso estabelece as condições para acesso e utilização do aplicativo Feijão no Prato.

Ao utilizar o aplicativo, o usuário declara ter lido, compreendido e concordado integralmente com este Termo e com a Política de Privacidade.

A utilização do aplicativo no contexto de pesquisa científica estará condicionada à prévia aceitação do Termo de Consentimento Livre e Esclarecido (TCLE), que regula especificamente a participação do usuário na pesquisa.

Caso o usuário não concorde com quaisquer das condições aqui previstas, deverá abster-se de utilizar o aplicativo.

**2. IDENTIFICAÇÃO, ORIGEM E FINALIDADE**

O aplicativo Feijão no Prato é uma ferramenta digital de educação alimentar baseada no Guia Alimentar para a População Brasileira.

O aplicativo foi desenvolvido por pesquisadoras do NUPENS (Núcleo de Pesquisas Epidemiológicas em Nutrição e Saúde), vinculado à Faculdade de Saúde Pública da USP.

O aplicativo integra a pesquisa científica "Prevenção de doenças com a dieta brasileira: o ensaio clínico PREDIBRA".

Sua finalidade é promover a alimentação adequada e saudável por meio de recursos educativos e tecnológicos e, quando aplicável, assistenciais no âmbito da nutrição.

**3. NATUREZA DOS SERVIÇOS**

Os serviços disponibilizados possuem natureza:

- Educativa e informativa;
- Tecnológica de apoio ao registro e análise do consumo alimentar;
- Complementar a acompanhamento nutricional, quando aplicável.

O aplicativo é autoinstrucional e não substitui atendimento de profissional da saúde para fins de diagnóstico, prescrição ou tratamento em saúde realizado por profissional da saúde.

**4. FUNCIONALIDADES**

O aplicativo poderá disponibilizar, entre outras:

- Conteúdos educativos sobre alimentação;
- Materiais complementares;
- Orientação para composição de refeições;
- Registro e acompanhamento do consumo alimentar;
- Análise de refeições por inteligência artificial.

As funcionalidades poderão ser modificadas, suspensas ou descontinuadas a qualquer tempo.

**5. USO DE IMAGENS E INTELIGÊNCIA ARTIFICIAL**

Ao utilizar funcionalidades que envolvam envio de imagens, o usuário:

- Autoriza o processamento dessas imagens por sistemas de inteligência artificial para análise do consumo alimentar;
- Declara ciência de que as imagens poderão ser armazenadas, inclusive para aprimoramento dos serviços, desenvolvimento tecnológico e pesquisa científica;
- Reconhece que os dados poderão ser tratados de forma anonimizada ou pseudonimizada, quando aplicável.

O usuário é responsável pelo conteúdo enviado e por garantir que possui os direitos necessários sobre ele.

**6. USO DE DADOS PARA PESQUISA**

O aplicativo integra protocolo de pesquisa científica vinculado ao estudo "Prevenção de doenças crônicas não transmissíveis com a dieta brasileira: o ensaio clínico PREDIBRA".

Nesse contexto:

- Os dados coletados poderão ser utilizados para fins científicos;
- O tratamento observará normas éticas e regulamentares aplicáveis;
- Os dados poderão ser utilizados de forma anonimizada ou pseudonimizada.

**8. PROTEÇÃO DE DADOS PESSOAIS**

O tratamento de dados pessoais observará a Lei Geral de Proteção de Dados Pessoais (LGPD) e demais normas aplicáveis.

**9. RESPONSABILIDADES**

**9.1 Do usuário**

O usuário compromete-se a utilizar o aplicativo de forma lícita e adequada, fornecer informações verídicas e não violar direitos de terceiros.

**9.2 Do aplicativo**

O aplicativo compromete-se a disponibilizar os serviços conforme descrito e adotar medidas razoáveis de segurança da informação.

**10. LIMITAÇÃO DE RESPONSABILIDADE**

O aplicativo não garante resultados específicos decorrentes do uso e não se responsabiliza por decisões tomadas com base exclusiva nas informações fornecidas.

**11. PROPRIEDADE INTELECTUAL**

Todos os conteúdos, marcas, tecnologias e elementos do aplicativo são protegidos por direitos de propriedade intelectual, sendo vedada sua reprodução ou utilização sem autorização.

**12. ALTERAÇÕES DO TERMO**

Este Termo poderá ser atualizado a qualquer tempo. A continuidade do uso do aplicativo após alterações implicará concordância com a versão vigente.

**13. CONTATO**

Em caso de dúvidas: feijaonoprato@fsp.usp.br
"""

    static let politicaPrivacidade = """
Última atualização: 04 de novembro de 2026

**1. APRESENTAÇÃO**

O aplicativo Feijão no Prato tem o compromisso com a proteção de dados pessoais e com a transparência no seu tratamento.

Esta Política de Privacidade explica, de forma clara e acessível, como os dados pessoais dos usuários são coletados, utilizados, compartilhados e protegidos, em conformidade com a Lei Geral de Proteção de Dados Pessoais (LGPD).

**2. CONTROLADOR DOS DADOS**

O tratamento de dados pessoais é realizado sob responsabilidade do NUPENS - USP.

**3. DADOS COLETADOS**

**3.1 Dados fornecidos pelo usuário**

- Nome, e-mail e data de nascimento: utilizados para identificação, contato e organização da participação na pesquisa;
- Informações sobre consumo alimentar: coletadas por meio de questionários estruturados;
- Fotos de refeições enviadas no aplicativo.

**3.2 Dados coletados automaticamente**

- Tipo de dispositivo e sistema operacional;
- Dados de uso do aplicativo;
- Registros técnicos e de navegação.

**4. FINALIDADES DO TRATAMENTO**

Os dados pessoais são processados e utilizados para:

- Permitir autenticação e funcionamento da conta do usuário;
- Analisar refeições e fornecer feedback educativo por inteligência artificial;
- Melhorar o desempenho, a segurança e a usabilidade;
- Desenvolver e validar pesquisas científicas.

**5. USO DE IMAGENS E INTELIGÊNCIA ARTIFICIAL**

As imagens de pratos de refeições enviadas pelo usuário são processadas por sistemas de inteligência artificial e podem ser armazenadas para aprimoramento do aplicativo e desenvolvimento de pesquisa científica.

**6. BASE LEGAL PARA TRATAMENTO**

O tratamento de dados pessoais é realizado conforme a LGPD, com base em: execução das funcionalidades do aplicativo, legítimo interesse, consentimento do usuário e realização de estudos por órgão de pesquisa.

**7. COMPARTILHAMENTO DE DADOS**

Os dados poderão ser compartilhados com prestadores de serviços tecnológicos necessários ao funcionamento do aplicativo, equipe de pesquisa de forma anonimizada, e autoridades públicas quando exigido por lei. Os dados não são vendidos ou comercializados.

**8. ARMAZENAMENTO E RETENÇÃO**

Os dados pessoais serão armazenados pelo tempo necessário para cumprir as finalidades descritas nesta Política. Considerando a natureza acadêmica e científica do projeto, os dados poderão ser mantidos por período prolongado.

**9. DIREITOS DO TITULAR**

Nos termos da LGPD, o usuário pode, a qualquer momento, confirmar a existência de tratamento de seus dados, acessar seus dados pessoais, corrigir dados incompletos, solicitar a exclusão de dados, revogar o consentimento, entre outros direitos.

**10. SEGURANÇA DA INFORMAÇÃO**

São adotadas medidas técnicas e administrativas adequadas para proteger os dados pessoais contra acessos não autorizados.

**11. TRANSFERÊNCIA INTERNACIONAL DE DADOS**

Caso sejam utilizados serviços tecnológicos localizados fora do Brasil, poderá ocorrer transferência internacional de dados, sempre em conformidade com a legislação aplicável.

**12. ALTERAÇÕES NA POLÍTICA**

Esta Política poderá ser atualizada a qualquer momento. Em caso de alterações relevantes, o usuário será informado por meio do aplicativo ou por e-mail.

**13. CONTATO**

E-mail: feijaonoprato@fsp.usp.br

**14. DISPOSIÇÕES FINAIS**

Esta Política deve ser interpretada em conjunto com o Termo de Uso do aplicativo e com o Termo de Consentimento Livre e Esclarecido (TCLE).
"""
}

// MARK: - ProfileTextView (ProfileTextScreen.kt port)

struct ProfileTextView: View {

    let title: String
    var dismiss: () -> Void

    private var content: String { ProfileTexts.text(for: title) }
    private var lines: [String] { content.components(separatedBy: "\n") }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    lineView(for: line)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: dismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(16)
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)
                Spacer()
            }
            .background(Color(.systemBackground))
        }
    }

    // MARK: Line rendering (mirrors ProfileTextScreen.kt helpers)

    @ViewBuilder
    private func lineView(for line: String) -> some View {
        if line.trimmingCharacters(in: .whitespaces).isEmpty {
            Spacer().frame(height: 8)
        } else if isSectionTitle(line) {
            Text(cleanSectionTitle(line))
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 16)
                .padding(.bottom, 4)
        } else if isBullet(line) {
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                styledText(cleanBullet(line))
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 4)
        } else {
            styledText(line)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .padding(.bottom, 4)
        }
    }

    // `**text**` spanning the whole line = section title
    private func isSectionTitle(_ line: String) -> Bool {
        let t = line.trimmingCharacters(in: .whitespaces)
        return t.hasPrefix("**") && t.hasSuffix("**") && t.count > 4
    }

    private func isBullet(_ line: String) -> Bool {
        line.hasPrefix("- ")
    }

    private func cleanSectionTitle(_ line: String) -> String {
        var t = line.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("**") { t = String(t.dropFirst(2)) }
        if t.hasSuffix("**") { t = String(t.dropLast(2)) }
        return t
    }

    private func cleanBullet(_ line: String) -> String {
        line.hasPrefix("- ") ? String(line.dropFirst(2)) : line
    }

    // Inline **bold** support using AttributedString
    private func styledText(_ raw: String) -> Text {
        var result = Text("")
        let parts = raw.components(separatedBy: "**")
        for (i, part) in parts.enumerated() {
            if i % 2 == 1 {
                result = result + Text(part).bold()
            } else {
                result = result + Text(part)
            }
        }
        return result
    }
}
