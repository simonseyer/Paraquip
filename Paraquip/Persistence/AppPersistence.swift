//
//  AppPersistence.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

class AppPersistence {

    private let basePath: URL
    private let fileManager: FileManager

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var url: URL {
        basePath.appendingPathComponent("app").appendingPathExtension("json")
    }

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.basePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func save(profiles: [UUID]) {
        do {
            let data = try encoder.encode(profiles)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to write app data: \(error)")
        }
    }

    func load() -> [UUID]? {
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([UUID].self, from: data)
        } catch {
            print("Failed to load app data: \(error)")
            return nil
        }
    }

    private func url(for id: UUID) -> URL {
        return basePath.appendingPathComponent(id.uuidString).appendingPathExtension("json")
    }
}
