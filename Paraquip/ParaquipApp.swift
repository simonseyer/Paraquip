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
    private let databaseMigration: DatabaseMigration
    private let notificationService: NotificationService
    private let logger = Logger(category: "ParaquipApp")
    
    @Environment(\.scenePhase) var scenePhase

    init() {
        if ProcessInfo.processInfo.environment["animationsDisabled"] == "true" {
            UIView.setAnimationsEnabled(false)
        }

        if ProcessInfo.processInfo.environment["stateSimulated"] == "true" {
            self.container = CoreData.inMemoryPersistentContainer
        } else {
            let container = NSPersistentContainer(name: "Model")
            container.loadPersistentStores { description, error in
                if let error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }

            self.container = container
        }

        if ProcessInfo.processInfo.environment["notificationsSimulated"] == "true" {
            self.notificationService = NotificationService(
                state: .fake(),
                managedObjectContext: container.viewContext,
                persistence: NotificationPersistence(),
                notifications: FakeNotificationPlugin()
            )
        } else {
            self.notificationService = NotificationService(managedObjectContext: container.viewContext)
        }

        let migrationContext = container.newBackgroundContext()
        self.databaseMigration = DatabaseMigration(context: migrationContext)

        if ProcessInfo.processInfo.environment["stateSimulated"] != "true" {
            LegacyAppPersistence().migrate(into: migrationContext)
            databaseMigration.run()
            initializeDatabase(context: migrationContext)
        }
    }

    private func initializeDatabase(context: NSManagedObjectContext) {
        let profiles = (try? context.count(for: Profile.fetchRequest())) ?? 0
        guard profiles == 0 else {
            return
        }

        _ = Profile.create(context: context, name: LocalizedString("Your Equipment"))

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
                .environmentObject(databaseMigration)
                .environment(\.managedObjectContext, container.viewContext)
        }
        .onChange(of: scenePhase) {
            if container.viewContext.hasChanges {
                try? container.viewContext.save()
            }
        }
    }
}
