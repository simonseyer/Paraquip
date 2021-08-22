//
//  LegacyAppPersistence.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import OSLog
import Versionable

class LegacyAppPersistence {

    private let basePath: URL
    private let fileManager: FileManager
    private let logger = Logger(category: "AppPersistence")

    private let decoder = JSONDecoder()

    private var url: URL {
        basePath.appendingPathComponent("app").appendingPathExtension("json")
    }

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.basePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func migrate(into store: ProfileStore) {
        guard let profileId = load()?.first,
              let profile = load(with: profileId) else {
            return
        }

        for equipment in profile.toModel().equipment {
            store.store(equipment: equipment)
            for check in equipment.checkLog {
                store.logCheck(at: check.date, for: equipment)
            }
        }

        let backupURL = url.appendingPathExtension("bak")
        try? fileManager.removeItem(at: backupURL)
        try? fileManager.moveItem(at: url, to: backupURL)
    }

    private func load() -> [UUID]? {
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([UUID].self, from: data)
        } catch {
            return nil
        }
    }

    func load(with id: UUID) -> PersistedProfile? {
        do {
            let url = basePath.appendingPathComponent(id.uuidString).appendingPathExtension("json")
            let data = try Data(contentsOf: url)
            let container = try decoder.decode(VersionableContainer<PersistedProfile>.self, from: data)
            return container.instance
        } catch {
            return nil
        }
    }
}
