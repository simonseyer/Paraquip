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
    @ObservedObject private var notificationsStore = NotificationsStore()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ProfileView()
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
                notificationsStore.resetShowNotificationSettings()
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
