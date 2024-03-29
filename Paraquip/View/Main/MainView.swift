//
//  MainView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct MainView: View {

    enum Tab {
        case equipment
        case checks
        case performance
    }

    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var databaseMigration: DatabaseMigration
    @Environment(\.managedObjectContext) private var managedObjectContext

    @State private var showNotificationSettings = false
    @State private var isShowingSingleEquipmentMigrationInfo = false
    @State private var selectedTab: Tab = .equipment
    @State private var isFirstAppearance = true
    @State private var checksProfileFilter: Profile? = nil

    var body: some View {
        TabView(selection: $selectedTab.animation()) {
            EquipmentView()
            .tag(Tab.equipment)
            .tabItem {
                Label("Equipment", systemImage: "backpack")
            }

            ChecksView(showNotificationSettings: $showNotificationSettings,
                       profileFilter: $checksProfileFilter)
            .tag(Tab.checks)
            .tabItem {
                Label("Checks", systemImage: "checkmark")
            }

            PerformanceView()
            .tag(Tab.performance)
            .tabItem {
                Label("Performance", systemImage: "gauge.open.with.lines.needle.33percent")
            }
        }
        .onChange(of: notificationService.navigationState) {
            switch notificationService.navigationState {
            case .notificationSettings:
                showNotificationSettings = true
            case .equipment:
                selectedTab = .checks
                checksProfileFilter = nil
            case .none:
                break
            }
            notificationService.resetNavigationState()
        }
        .alert("Sets updated",
               isPresented: $isShowingSingleEquipmentMigrationInfo) {
            Button("Ok") {}
        } message: {
            Text("single_equipment_migration_info")
        }
        .onChange(of: databaseMigration.hasRemovedDuplicateEquipment) {
            isShowingSingleEquipmentMigrationInfo = databaseMigration.hasRemovedDuplicateEquipment
        }
        .onAppear {
            if isFirstAppearance {
                let equipmentCount = try? managedObjectContext.count(for: Equipment.fetchRequest())
                if equipmentCount ?? 0 > 0 {
                    selectedTab = .checks
                }
                isFirstAppearance = false
            }
        }
    }
}

#Preview {
    MainView()
        .environment(\.managedObjectContext, .preview)
        .environmentObject(NotificationService(managedObjectContext: .preview,
                                               notifications: FakeNotificationPlugin()))
        .environmentObject(DatabaseMigration(context: .preview))
        .environment(\.locale, .init(identifier: "de"))
}
