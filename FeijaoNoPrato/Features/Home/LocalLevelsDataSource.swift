// LocalLevelsDataSource.swift
// Replaces data/model/module/LocalJsonDataSource.kt

import Foundation

final class LocalLevelsDataSource {
    func loadLevels() -> [LevelData] {
        guard
            let url = Bundle.main.url(forResource: "levels", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let root = try? JSONDecoder().decode(LevelRoot.self, from: data)
        else {
            return []
        }
        return root.level
    }
}
