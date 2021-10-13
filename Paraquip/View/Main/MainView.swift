//
//  MainView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct MainView: View {

    enum Tabs: String {
        case profile, notifications
    }

    @EnvironmentObject var notificationService: NotificationService

    @State private var selectedTab: Tabs = .profile
    @State private var presentedEquipment: Equipment? = nil

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ProfileListView()
            }
            .tabItem {
                Label("Equipment", systemImage: "book.closed.fill")
            }
            .tag(Tabs.profile)
            
            NavigationView {
                NotificationSettingsView()
            }
            .tabItem {
                Label("Notifications", systemImage: "bell.fill")
            }
            .tag(Tabs.notifications)
        }
        .onChange(of: notificationService.navigationState, perform: { value in
            switch value {
            case .notificationSettings:
                selectedTab = .notifications
            case .equipment(let equipmentId):
                selectedTab = .profile
                presentedEquipment = equipmentId
            case .none:
                break
            }
            notificationService.resetNavigationState()
        })
        .sheet(item: $presentedEquipment) { equipment in
            NavigationView {
                EquipmentView(equipment: equipment)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
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
            .environmentObject(NotificationService(managedObjectContext: CoreData.previewContext))
    }
}

