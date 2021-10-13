//
//  ParaquipApp.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData
import OSLog

@main
struct ParaquipApp: App {

    private let container: NSPersistentContainer
    private let notificationService: NotificationService
    private let logger = Logger(category: "ParaquipApp")

    init() {
        if ProcessInfo.processInfo.environment["isUITest"] == "true" {
            self.container = NSPersistentContainer.fake(name: "Model")
            self.notificationService = NotificationService(
                state: .fake(),
                managedObjectContext: container.viewContext,
                persistence: NotificationPersistence(),
                notifications: FakeNotificationPlugin()
            )
        } else {
            let container = NSPersistentContainer(name: "Model")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }

            self.container = container
            self.notificationService = NotificationService(managedObjectContext: container.viewContext)

            let migrationContext = container.newBackgroundContext()
            LegacyAppPersistence().migrate(into: migrationContext)
            migrateDatabase(context: migrationContext)
            initializeDatabase(context: migrationContext)
        }
    }

    private func migrateDatabase(context: NSManagedObjectContext) {
        let profilesFetchRequest = Profile.fetchRequest()
        let profiles = (try? context.fetch(profilesFetchRequest)) ?? []

        guard profiles.count == 1,
              let profile = profiles.first,
              profile.name == "Paraquip",
              profile.equipment?.count ?? 0 == 0 else {
                  return
              }

        profile.name = NSLocalizedString("Equipment", comment: "")

        let equipmentFetchRequest = Equipment.fetchRequest()
        let equipment = (try? context.fetch(equipmentFetchRequest)) ?? []

        for equipment in equipment {
            profile.addToEquipment(equipment)
        }

        do {
            try context.save()
        } catch {
            logger.error("Failed to migrate database from v0 to v1: \(error.description)")
        }
    }

    private func initializeDatabase(context: NSManagedObjectContext) {
        let profiles = (try? context.count(for: Profile.fetchRequest())) ?? 0
        guard profiles == 0 else {
            return
        }

        let profile = Profile.create(context: context)
        profile.name = NSLocalizedString("Equipment", comment: "")

        do {
            try context.save()
        } catch {
            logger.error("Failed to initialise empty database: \(error.description)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(notificationService)
                .environment(\.managedObjectContext, container.viewContext)
        }
    }
}
