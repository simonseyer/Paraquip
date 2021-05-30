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
    @ObservedObject private var notificationsStore = NotificationsStore(profileStore: AppStore.shared.profileStore(for: AppStore.shared.profiles.first!)!)

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ProfileView(selectedEquipment: $selectedEquipment)
            }
            .environmentObject(store.profileStore(for: store.profiles.first!)!)
            .tabItem {
                Label("Equipment", systemImage: "book.closed")
            }
            .tag(Tabs.profile)
            
            NavigationView {
                NotificationSettingsView()
                    .environmentObject(notificationsStore)
            }
            .tabItem {
                Label("Notifications", systemImage: "bell")
            }
            .tag(Tabs.notifications)
        }
        .onChange(of: notificationsStore.state.showNotificationSettings, perform: { value in
            if value {
                selectedTab = .notifications
                notificationsStore.resetShowState()
            }
        })
        .onChange(of: notificationsStore.state.showEquipment, perform: { value in
            if let equipmentId = value {
                selectedTab = .profile
                selectedEquipment = equipmentId
                notificationsStore.resetShowState()
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppStore())
    }
}
