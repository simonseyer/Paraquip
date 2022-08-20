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
                Text(equipment.brandName)
                    .foregroundStyle(.secondary)
                Text(equipment.equipmentName)
                Spacer()
                if profile.contains(equipment) {
                    Image(systemName: "checkmark")
                        .font(.system(.body).weight(.medium))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .foregroundColor(.primary)
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
