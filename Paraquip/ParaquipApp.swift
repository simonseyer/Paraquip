//
//  ParaquipApp.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

@main
struct ParaquipApp: App {

    init() {
        LegacyAppPersistence().migrate(into: AppStore.shared.mainProfileStore)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppStore.shared)
        }
    }
}
