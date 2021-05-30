//
//  ProfilePersistence.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import Versionable
import OSLog

class ProfilePersistence {

    private let basePath: URL
    private let fileManager: FileManager
    private let logger = Logger(category: "ProfilePersistence")

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.basePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func save(profile: PersistedProfile) {
        do {
            let url = url(for: profile.id)
            let container = VersionableContainer(instance: profile)
            let data = try encoder.encode(container)
            try data.write(to: url, options: .atomic)
        } catch {
            logger.error("Failed to write profile: \(error.localizedDescription)")
        }
    }

    func load(with id: UUID) -> PersistedProfile? {
        do {
            let url = url(for: id)
            let data = try Data(contentsOf: url)
            let container = try decoder.decode(VersionableContainer<PersistedProfile>.self, from: data)
            return container.instance
        } catch {
            logger.error("Failed to load profile: \(error.localizedDescription)")
            return nil
        }
    }

    private func url(for id: UUID) -> URL {
        return basePath.appendingPathComponent(id.uuidString).appendingPathExtension("json")
    }
}
