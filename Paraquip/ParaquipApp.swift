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
            self.container = CoreData.inMemoryPersistentContainer
            self.notificationService = NotificationService(
                state: .fake(),
                managedObjectContext: container.viewContext,
                persistence: NotificationPersistence(),
                notifications: FakeNotificationPlugin()
            )
        } else if ProcessInfo.processInfo.environment["isNotificationTest"] == "true" {
            self.container = CoreData.inMemoryPersistentContainer
            self.notificationService = NotificationService(managedObjectContext: container.viewContext)
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

        let equipmentFetchRequest = Equipment.fetchRequest()
        let equipment = (try? context.fetch(equipmentFetchRequest)) ?? []

        for equipment in equipment {
            if let purchaseDate = equipment.purchaseDate, equipment.purchaseLog == nil {
                equipment.purchaseLog = Check.create(context: context, date: purchaseDate)
                equipment.purchaseDate = nil
            }
        }

        if profiles.count == 1,
           let profile = profiles.first,
           profile.name == "Paraquip",
           profile.equipment?.count ?? 0 == 0 {
            profile.name = NSLocalizedString("Your Equipment", comment: "")

            for equipment in equipment {
                profile.addToEquipment(equipment)
            }
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

        _ = Profile.create(context: context, name: NSLocalizedString("Your Equipment", comment: ""))

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
