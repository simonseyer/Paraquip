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

    @FetchRequest(sortDescriptors: [])
    private var equipment: FetchedResults<Equipment>

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @State private var profileFilter: Profile? = nil

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
                    ChecksListView(checks: checks)
                } else {
                    ChecksGridView(checks: checks)
                }
            }
            .navigationTitle("Checks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Picker("Filter by a set", selection: $profileFilter.animation()) {
                        Label("All Equipment",
                              systemImage: "line.3.horizontal.decrease.circle.fill".deviceSpecificIcon)
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
                        Label("Set up notifications", systemImage: "bell.fill".deviceSpecificIcon)
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
    ChecksView(showNotificationSettings: .constant(false))
    .environment(\.managedObjectContext, .preview)
}
