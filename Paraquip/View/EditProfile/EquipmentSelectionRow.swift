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
                    .foregroundStyle(.primary)
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

struct EquipmentSelectionRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            EquipmentSelectionRow(
                profile: CoreData.fakeProfile,
                equipment: CoreData.fakeProfile.allEquipment.first!
            )
        }
        #if os(visionOS)
        .glassBackgroundEffect()
        #endif
    }
}
