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

    @State private var showNotificationSettings = false
    @State private var isShowingSingleEquipmentMigrationInfo = false

    @State private var selectedTab: Tab = .equipment
    @State private var selectedProfile: ProfileSelection?
    @State private var selectedEquipment: Equipment?

    @State private var columnVisibility: NavigationSplitViewVisibility = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .doubleColumn
        } else {
            return .all
        }
    }()

    var body: some View {
        TabView(selection: $selectedTab.animation()) {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                ProfileListView(selectedProfile: $selectedProfile.animation())
            } content: {
                switch selectedProfile {
                case .none:
                    ContentUnavailableView("Select an equipment set",
                                           systemImage: "tray.full.fill")
                case .allEquipment:
                    AllEquipmentProfileView(selectedEquipment: $selectedEquipment.animation())
                case .profile(let profile):
                    ProfileView(profile: profile,
                                selectedEquipment: $selectedEquipment.animation())
                }
            } detail: {
                if let selectedEquipment {
                    EditEquipmentView(equipment: selectedEquipment)
                } else if let selectedProfile {
                    if case .profile(let profile) = selectedProfile, profile.allEquipment.isEmpty {
                        ContentUnavailableView("Create an equipment first", systemImage: "backpack.fill")
                    } else {
                        ContentUnavailableView("Select an equipment",
                                               systemImage: "backpack.fill")
                    }
                } else {
                    EmptyView()
                }
            }
            .tag(Tab.equipment)
            .tabItem {
                Label("Equipment", systemImage: "backpack")
            }
            ChecksView(showNotificationSettings: $showNotificationSettings)
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
        .onChange(of: selectedProfile) {
            guard let selectedProfile else {
                self.selectedEquipment = nil
                return
            }

            if case .profile(let profile) = selectedProfile, let selectedEquipment, !(profile.equipment?.contains(selectedEquipment) ?? false) {
                self.selectedEquipment = nil
            }
        }
        .onChange(of: notificationService.navigationState) {
            switch notificationService.navigationState {
            case .notificationSettings:
                showNotificationSettings = true
            case .equipment:
                selectedTab = .checks
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
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, .preview)
            .environmentObject(NotificationService(managedObjectContext: .preview,
                                                   notifications: FakeNotificationPlugin()))
            .environmentObject(DatabaseMigration(context: .preview))
            .environment(\.locale, .init(identifier: "de"))
    }
}

