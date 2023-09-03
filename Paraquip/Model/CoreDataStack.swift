//
//  CoreDataStack.swift
//  Paraquip
//
//  Created by Simon Seyer on 31.08.23.
//

import Foundation
import CoreData
import OSLog

@MainActor
class CoreDataStack {
    let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext
    let databaseMigration: DatabaseMigration

    private static let modelName = "Model"
    private static let logger = Logger(category: "CoreDataStack")

    init() {
        let container = NSPersistentContainer(name: Self.modelName)
        let storeURL = AppGroup.paraquip.containerURL.appendingPathComponent("\(Self.modelName).sqlite")
        let databaseMigration = DatabaseMigration()

        var currentStoreURL: URL?
        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url {
            currentStoreURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
        }

        if currentStoreURL == nil {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }
        container.loadPersistentStores(completionHandler: { [unowned container] (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            // Migrate from documents directory to app group
            if let currentStoreURL, currentStoreURL.absoluteString != storeURL.absoluteString {
                let coordinator = container.persistentStoreCoordinator
                if let oldStore = coordinator.persistentStore(for: currentStoreURL) {
                    do {
                        try coordinator.migratePersistentStore(oldStore, to: storeURL, options: nil, withType: NSSQLiteStoreType)
                        Self.logger.info("Migrated store from \(currentStoreURL) to \(storeURL)")

                        // Delete old store
                        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
                        fileCoordinator.coordinate(writingItemAt: currentStoreURL, options: .forDeleting, error: nil) { url in
                            do {
                                try FileManager.default.removeItem(at: url)
                                Self.logger.info("Deleted old store at \(url)")
                            } catch {
                                Self.logger.error("Error deleting old store: \(error.localizedDescription)")
                            }
                        }
                    } catch {
                        Self.logger.error("Error migrating store: \(error.localizedDescription)")
                    }
                }
            }

            let migrationContext = container.newBackgroundContext()
            LegacyAppPersistence().migrate(into: migrationContext)
            databaseMigration.run(context: migrationContext)
            Self.initializeDatabase(context: migrationContext)
        })

        self.databaseMigration = databaseMigration
        self.container = container
        self.viewContext = container.viewContext
    }

    private static func initializeDatabase(context: NSManagedObjectContext) {
        let profiles = (try? context.count(for: Profile.fetchRequest())) ?? 0
        guard profiles == 0 else {
            return
        }

        _ = Profile.create(context: context, name: LocalizedString("Your Equipment"))

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to initialise empty database: \(error.description)")
        }
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

