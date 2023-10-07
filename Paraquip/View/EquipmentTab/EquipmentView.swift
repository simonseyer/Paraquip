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
                        selectedEquipment: $selectedEquipment)
        } detail: {
            EditEquipmentView(profile: selectedProfile?.profile,
                              equipment: selectedEquipment)
        }
        .onChange(of: selectedProfile) {
            guard let selectedProfile else {
                self.selectedEquipment = nil
                return
            }

            if case .profile(let profile) = selectedProfile, let selectedEquipment, !(profile.equipment?.contains(selectedEquipment) ?? false) {
                self.selectedEquipment = nil
            }
        }
    }
}

#Preview {
    EquipmentView()
        .environment(\.managedObjectContext, .preview)
}
