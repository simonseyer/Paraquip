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

    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var notificationsStore: NotificationsStore

    @State private var selectedTab: Tabs = .profile
    @State private var selectedEquipment: UUID? = nil

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ProfileView(viewModel: viewModel, selectedEquipment: $selectedEquipment)
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

    static let profileStore = FakeProfileStore(profile: .fake())

    static var previews: some View {
        ContentView(viewModel: ProfileViewModel(store: profileStore))
            .environmentObject(NotificationsStore(profileStore: profileStore))
    }
}
