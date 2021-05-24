//
//  ContentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        TabView {
            NavigationView {
                ProfileView()
            }
            .environmentObject(store.profileStore(for: store.profiles.first!)!)
            .tabItem {
                Label("Equipment", systemImage: "book.closed")
            }
            
            NavigationView {
                NotificationSettingsView()
                    .environmentObject(NotificationsStore())
            }
            .tabItem {
                Label("Notifications", systemImage: "bell")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppStore())
    }
}
