//
//  MainView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct MainView: View {

    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var databaseMigration: DatabaseMigration

    @State private var showNotificationSettings = false
    @State private var presentedEquipment: Equipment? = nil
    @State private var isShowingSingleEquipmentMigrationInfo = false

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
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ProfileListView(selectedProfile: $selectedProfile)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showNotificationSettings = true
                        } label: {
                            Label("Notifications", systemImage: "bell.fill")
                        }
                    }
                }
        } content: {
            switch selectedProfile {
            case .none:
                ContentUnavailableView("Select an equipment set",
                                       systemImage: "tray.full.fill")
            case .allEquipment:
                ProfileView(profile: nil, selectedEquipment: $selectedEquipment)
            case .profile(let profile):
                ProfileView(profile: profile, selectedEquipment: $selectedEquipment)
            }
        } detail: {
            if let selectedEquipment {
                EquipmentView(equipment: selectedEquipment)
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
        .onChange(of: notificationService.navigationState) { _, value in
            switch value {
            case .notificationSettings:
                showNotificationSettings = true
            case .equipment(let equipmentId):
                presentedEquipment = equipmentId
            case .none:
                break
            }
            notificationService.resetNavigationState()
        }
        .sheet(isPresented: $showNotificationSettings) {
            NavigationStack {
                NotificationSettingsView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Close") {
                                showNotificationSettings = false
                            }
                        }
                    }
            }
        }
        .sheet(item: $presentedEquipment) { equipment in
            NavigationStack {
                EquipmentView(equipment: equipment)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Close") {
                                presentedEquipment = nil
                            }
                        }
                    }
            }
        }
        .alert("Sets updated",
               isPresented: $isShowingSingleEquipmentMigrationInfo) {
            Button("Ok") {}
        } message: {
            Text("single_equipment_migration_info")
        }
        .onChange(of: databaseMigration.hasRemovedDuplicateEquipment) { _, newValue in
            isShowingSingleEquipmentMigrationInfo = newValue
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

