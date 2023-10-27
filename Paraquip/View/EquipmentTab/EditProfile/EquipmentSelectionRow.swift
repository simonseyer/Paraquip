//
//  EquipmentSelectionRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.06.22.
//

import SwiftUI

struct EquipmentSelectionRow: View {

    @ObservedObject var profile: Profile
    @ObservedObject var equipment: Equipment

    var body: some View {
        Button(action: { profile.toggle(equipment) }) {
            HStack {
                EquipmentRow(equipment: equipment)
                Spacer()
                if profile.contains(equipment) {
                    Image(systemName: "checkmark")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    List {
        EquipmentSelectionRow(
            profile: CoreData.fakeProfile,
            equipment: CoreData.fakeProfile.allEquipment.first!
        )
    }
}
