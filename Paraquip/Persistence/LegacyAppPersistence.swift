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
        loadSnapshotData()
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

        try? fileManager.moveItem(at: url, to: url.appendingPathExtension("bak"))
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

    private func loadSnapshotData() {
        guard let contentsURL = Bundle.main.url(forResource: "Snapshot", withExtension: "xcappdata")?.appendingPathComponent("AppData").appendingPathComponent("Documents") else {
            return
        }

        logger.info("Found Snapshot.xcappdata — copying data")

        guard let destinationRoot = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        guard let enumerator = fileManager.enumerator(at: contentsURL,
                                                      includingPropertiesForKeys: [],
                                                      options: [],
                                                      errorHandler: nil) else {
            return
        }

        while let sourceURL = enumerator.nextObject() as? URL {
            let destinationURL = destinationRoot.appendingPathComponent(sourceURL.lastPathComponent)

            logger.info("Copying \(sourceURL) to \(destinationURL)")

            try? fileManager.removeItem(at: destinationURL)

            do {
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
            } catch {
                logger.error("Failed to copy file \(sourceURL.lastPathComponent): \(error.localizedDescription)")
            }
        }
    }
}
