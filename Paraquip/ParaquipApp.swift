//
//  ParaquipApp.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

@main
struct ParaquipApp: App {

    private let container: NSPersistentContainer
    private let notificationsStore: NotificationsStore

    init() {
        if ProcessInfo.processInfo.environment["isUITest"] == "true" {
            self.container = NSPersistentContainer.fake(name: "Model")
            self.notificationsStore = NotificationsStore(
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
            self.notificationsStore = NotificationsStore(managedObjectContext: container.viewContext)

            let migrationContext = container.newBackgroundContext()
            LegacyAppPersistence().migrate(into: migrationContext)
            migrateDatabase(context: migrationContext)
            initializeDatabase(context: migrationContext)
        }
    }

    private func migrateDatabase(context: NSManagedObjectContext) {
        let profilesFetchRequest = ProfileModel.fetchRequest()
        let profiles = (try? context.fetch(profilesFetchRequest)) ?? []

        guard profiles.count == 1,
              let profile = profiles.first,
              profile.name == "Paraquip",
              profile.equipment?.count ?? 0 == 0 else {
                  return
              }

        profile.name = NSLocalizedString("Equipment", comment: "")

        let equipmentFetchRequest = EquipmentModel.fetchRequest()
        let equipment = (try? context.fetch(equipmentFetchRequest)) ?? []

        for equipment in equipment {
            profile.addToEquipment(equipment)
        }

        try? context.save()
    }

    private func initializeDatabase(context: NSManagedObjectContext) {
        let profiles = (try? context.count(for: ProfileModel.fetchRequest())) ?? 0
        guard profiles == 0 else {
            return
        }

        let profile = ProfileModel.create(context: context)
        profile.name = NSLocalizedString("Equipment", comment: "")

        try? context.save()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationsStore)
                .environment(\.managedObjectContext, container.viewContext)
        }
    }
}
