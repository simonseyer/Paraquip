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
        HStack {
            Text(equipment.brandName)
                .foregroundStyle(.secondary)
            Text(equipment.equipmentName)
            Spacer()
            Button(action: { profile.toggle(equipment) }) {
                if profile.contains(equipment) {
                    Image(systemName: "checkmark")
                        .font(.system(.body).weight(.medium))
                }
            }
        }
    }
}

struct EquipmentSelectionRow_Previews: PreviewProvider {
    static var previews: some View {
        EquipmentSelectionRow(
            profile: CoreData.fakeProfile,
            equipment: CoreData.fakeProfile.allEquipment.first!
        )
    }
}
