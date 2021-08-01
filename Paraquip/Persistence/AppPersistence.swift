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
        loadSnapshotData()
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
