//
//  ChecksView.swift
//  Paraquip
//
//  Created by Simon Seyer on 17.09.23.
//

import SwiftUI
import CoreData

struct ChecksView: View {

    @Binding var showNotificationSettings: Bool
    @Binding var profileFilter: Profile?

    @FetchRequest(sortDescriptors: [])
    private var equipment: FetchedResults<Equipment>

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var checks: CheckList {
        let filteredEquipment = equipment.filter { equipment in
            if let profileFilter {
                profileFilter.contains(equipment)
            } else {
                true
            }
        }
        return CheckList(equipment: filteredEquipment)
    }

    var body: some View {
        NavigationStack {
            Group {
                if UIDevice.current.userInterfaceIdiom == .phone || horizontalSizeClass == .compact {
                    ChecksListView(checks: checks,
                                   profile: profileFilter)
                } else {
                    ChecksGridView(checks: checks)
                }
            }
            .navigationTitle("Checks")
            .toolbar {
                ToolbarItem {
                    Picker("Filter", selection: $profileFilter.animation()) {
                        Label("All Equipment",
                              systemImage: "line.3.horizontal.decrease.circle")
                        .tag(Optional<Profile>.none)
                        ForEach(profiles) { profile in
                            Label(profile.profileName,
                                  systemImage: profile.profileIcon.systemName)
                            .tag(Optional(profile))
                        }
                    }
                }
                ToolbarItem {
                    Button {
                        showNotificationSettings = true
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                }
            }
            #if os(iOS)
            .symbolVariant(.fill)
            #endif
            .onReceive(profiles.publisher) { _ in
                if let profileFilter = profileFilter {
                    if !profiles.contains(profileFilter) {
                        self.profileFilter = nil
                    }
                }
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
        }
    }
}

#Preview {
    ChecksView(showNotificationSettings: .constant(false), 
               profileFilter: .constant(nil))
    .environment(\.managedObjectContext, .preview)
}
