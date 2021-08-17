//
//  ContentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

struct ContentView: View {

    enum Tabs: String {
        case profile, notifications
    }
    
    @EnvironmentObject var store: AppStore

    @State private var selectedTab: Tabs = .profile
    @State private var selectedEquipment: UUID? = nil
    @ObservedObject private var notificationsStore = NotificationsStore(profileStore: AppStore.shared.mainProfileStore)

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ProfileView(selectedEquipment: $selectedEquipment)
            }
            .environmentObject(ProfileViewModel(store: store.mainProfileStore))
            .tabItem {
                Label("Equipment", systemImage: "book.closed.fill")
            }
            .tag(Tabs.profile)
            
            NavigationView {
                NotificationSettingsView()
                    .environmentObject(notificationsStore)
            }
            .tabItem {
                Label("Notifications", systemImage: "bell.fill")
            }
            .tag(Tabs.notifications)
        }
        .onChange(of: notificationsStore.navigationState, perform: { value in
            switch value {
            case .notificationSettings:
                selectedTab = .notifications
            case .equipment(let equipmentId):
                selectedTab = .profile
                selectedEquipment = equipmentId
            case .none:
                break
            }
            notificationsStore.resetNavigationState()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppStore.shared)
    }
}
