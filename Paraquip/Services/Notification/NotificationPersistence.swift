//
//  NotificationPersistence.swift
//  Paraquip
//
//  Created by Simon Seyer on 24.05.21.
//

import Foundation

import Foundation
import Versionable
import OSLog

class NotificationPersistence {

    private let fileURL: URL
    private let fileManager: FileManager
    private let logger = Logger(category: "NotificationPersistence")

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let basePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = basePath
            .appendingPathComponent("notificationState")
            .appendingPathExtension("json")
    }

    func save(notificationState: PersistedNotificationState) {
        do {
            let container = VersionableContainer(instance: notificationState)
            let data = try encoder.encode(container)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            logger.error("Failed to write notification state: \(error.localizedDescription)")
        }
    }

    func load() -> PersistedNotificationState? {
        do {
            let data = try Data(contentsOf: fileURL)
            let container = try decoder.decode(VersionableContainer<PersistedNotificationState>.self, from: data)
            return container.instance
        } catch {
            logger.error("Failed to load profile: \(error.localizedDescription)")
            return nil
        }
    }

}
