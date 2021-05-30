//
//  AppPersistence.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import OSLog

class AppPersistence {

    private let basePath: URL
    private let fileManager: FileManager
    private let logger = Logger(category: "AppPersistence")

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
            logger.error("Failed to write app data: \(error.localizedDescription)")
        }
    }

    func load() -> [UUID]? {
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([UUID].self, from: data)
        } catch {
            logger.error("Failed to load app data: \(error.localizedDescription)")
            return nil
        }
    }

    private func url(for id: UUID) -> URL {
        return basePath.appendingPathComponent(id.uuidString).appendingPathExtension("json")
    }
}
