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

    var body: some View {
        NavigationView {
            ProfileListView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showNotificationSettings = true
                        } label: {
                            Image(systemName: "bell.fill")
                        }
                    }
                }
        }
        .onChange(of: notificationService.navigationState) { value in
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
            NavigationView {
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
            NavigationView {
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
        .onChange(of: databaseMigration.hasRemovedDuplicateEquipment) { newValue in
            isShowingSingleEquipmentMigrationInfo = newValue
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, CoreData.previewContext)
            .environmentObject(NotificationService(managedObjectContext: CoreData.previewContext,
                                                   notifications: FakeNotificationPlugin()))
            .environmentObject(DatabaseMigration(context: CoreData.previewContext))
    }
}

