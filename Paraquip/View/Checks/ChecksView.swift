//
//  ChecksView.swift
//  Paraquip
//
//  Created by Simon Seyer on 17.09.23.
//

import SwiftUI
import CoreData

struct ChecksView: View {

    @FetchRequest(sortDescriptors: [])
    private var equipment: FetchedResults<Equipment>

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @State private var profileFilter: Profile? = nil

    private var checks: CheckList {
        let filteredEquipment = equipment.filter { equipment in
            if let profileFilter {
                profileFilter.contains(equipment)
            } else {
                true
            }
        }
        return CheckList(equipment: filteredEquipment) { equipment in
            // TODO: Handle tap
        }
    }

    var body: some View {
        ChecksGridView(checks: checks)
            .navigationTitle("Checks")
            .toolbar {
                Picker("Filter by a set", selection: $profileFilter) {
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
    }
}

#Preview {
    NavigationStack {
        ChecksView()
    }
    .environment(\.managedObjectContext, .preview)
}
