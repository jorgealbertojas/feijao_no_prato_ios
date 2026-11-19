// LevelModels.swift
// Replaces data/model/ModuleResposta.kt, ModelSection.kt, ModelParagraph.kt, SectionItemUi.kt

import Foundation

struct LevelRoot: Codable {
    let level: [LevelData]
}

struct LevelData: Codable {
    let name: String
    let imageUrl: String
    let position: String
    let progress: Double
    let progressSize: Int
    let progressStroke: Int
    let imageSize: Int
    let module: [ModuleData]
}

struct ModuleData: Codable {
    let name: String
    let title: String
    let imageUrl: String
    let position: String
    let progress: Int
    let progressSize: Int
    let progressStroke: Int
    let imageSize: Int
    let section: [SectionData]
}

struct SectionData: Codable {
    let name: String
    let module: String
    let nivel: String
    let nivel_name: String
    let title: String
    let body: String
    let imageUrl: String
    let position: String
    let progress: Float
    let progressSize: Int
    let progressStroke: Int
    let imageSize: Int
    let status: Int
    let time: String
    let paragraphs: [ParagraphData]?
}

struct ParagraphData: Codable {
    let name: String?
    let title: String?
    let title1: String?
    let body: String?
    let imageUrl: String?
    let subtitle: String?
    let question: String?
    let name2: String?
    let title2: String?
    let title3: String?
    let body2: String?
    let imageUrl2: String?
    let subtitle2: String?
    let question2: String?
    let subQuestion1: String?
    let subQuestion2: String?
    let button: String?
    let options: [String]?
    let optionCorrect: String?
    let button2: String?
    let showHeader: Bool?
    let button2Click: Int?
}

struct ProgressState {
    var currentModule: Int
    var currentSection: Int
}

struct SectionItemUi: Identifiable {
    let section: SectionData
    let moduleIndex: Int       // 1-based
    let sectionIndex: Int      // 0-based
    let globalIndex: Int       // 1-based, sequential across all modules
    let totalSectionsInModule: Int
    let totalPagesInSection: Int

    var id: String { "\(moduleIndex)_\(sectionIndex)_\(section.name)" }
    var sessaoDaVez: Int { sectionIndex + 1 }  // 1-based session number
}
