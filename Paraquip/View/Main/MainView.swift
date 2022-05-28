//
//  MainView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

extension UIColor {
    static var grayBackground = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
}

struct MainView: View {

    @EnvironmentObject var notificationService: NotificationService

    @State private var showNotificationSettings = false
    @State private var presentedEquipment: Equipment? = nil

    init() {
        applyGlobalStyles()
    }

    private func applyGlobalStyles() {
        UITableView.appearance().backgroundColor = .grayBackground
    }

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
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, CoreData.previewContext)
            .environmentObject(NotificationService(managedObjectContext: CoreData.previewContext,
                                                   notifications: FakeNotificationPlugin()))
    }
}

