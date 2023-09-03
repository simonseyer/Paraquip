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
        if ProcessInfo.processInfo.environment["isUITest"] == "true" {
            UIView.setAnimationsEnabled(false)
            self.container = CoreData.inMemoryPersistentContainer
            self.databaseMigration = DatabaseMigration()
            self.notificationService = NotificationService(
                state: .fake(),
                managedObjectContext: container.viewContext,
                persistence: NotificationPersistence(),
                notifications: FakeNotificationPlugin()
            )
        } else if ProcessInfo.processInfo.environment["isNotificationTest"] == "true" {
            self.container = CoreData.inMemoryPersistentContainer
            self.databaseMigration = DatabaseMigration()
            self.notificationService = NotificationService(managedObjectContext: container.viewContext)
        } else {
            let coreDataStack = CoreDataStack()
            self.container = coreDataStack.container
            self.databaseMigration = coreDataStack.databaseMigration
            self.notificationService = NotificationService(managedObjectContext: coreDataStack.viewContext)
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(notificationService)
                .environmentObject(databaseMigration)
                .environment(\.managedObjectContext, container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            if container.viewContext.hasChanges {
                try? container.viewContext.save()
            }
        }
    }
}
