//
//  ParaquipApp.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

@main
struct ParaquipApp: App {

    private let appStore: AppStore
    private let notificationsStore: NotificationsStore

    init() {
        if ProcessInfo.processInfo.environment["isUITest"] == "true" {
            self.appStore = FakeAppStore()
            self.notificationsStore = NotificationsStore(
                state: .fake(),
                profileStore: appStore.mainProfileStore,
                persistence: NotificationPersistence(),
                notifications: FakeNotificationPlugin()
            )
        } else {
            self.appStore = CoreDataAppStore()
            self.notificationsStore = NotificationsStore(profileStore: appStore.mainProfileStore)
        }
        LegacyAppPersistence().migrate(into: appStore.mainProfileStore)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ProfileViewModel(store: appStore.mainProfileStore))
                .environmentObject(notificationsStore)
        }
    }
}
