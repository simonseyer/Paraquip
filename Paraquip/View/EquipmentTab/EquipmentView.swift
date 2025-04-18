//
//  EquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 03.10.23.
//

import SwiftUI

struct EquipmentView: View {
    @State private var selectedProfile: ProfileSelection?
    @State private var selectedEquipment: Equipment?

    var body: some View {
        NavigationSplitView {
            ProfileListView(selectedProfile: $selectedProfile.animation())
        } content: {
            ProfileView(selectedProfile: selectedProfile,
                        selectedEquipment: $selectedEquipment.animation())
        } detail: {
            if let selectedEquipment {
                EditEquipmentView(equipment: selectedEquipment)
            } else {
                ContentUnavailableView("Select an equipment",
                                       systemImage: "backpack.fill")
            }
        }
        .onChange(of: selectedProfile) {
            // On deletion
            if selectedProfile == nil {
                selectedEquipment = nil
            }
        }
    }
}

#Preview {
    EquipmentView()
        .environment(\.managedObjectContext, .preview)
}
