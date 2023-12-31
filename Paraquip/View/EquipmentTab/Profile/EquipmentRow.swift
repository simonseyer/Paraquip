//
//  EquipmentRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import SwiftUI
import CoreData

struct EquipmentRow: View {

    @ObservedObject var equipment: Equipment

    private var equipmentName: String {
        if equipment.equipmentName.isEmpty {
            equipment.equipmentType.localizedName
        } else {
            equipment.equipmentName
        }
    }
    private var brandName: String {
        if equipment.brandName.isEmpty {
            String(localized: "Unknown")
        } else {
            equipment.brandName
        }
    }

    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(equipmentName)
                Text(brandName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        } icon: {
            equipment.equipmentType.iconImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 2)
                // Fix icon alignment
                .padding(.bottom, -20)

        }
    }
}

private func equipment(for brand: String, type: Equipment.EquipmentType = .reserve) -> Equipment {
    let equipment = Equipment.create(type, context: .preview)
    equipment.brandName = brand
    equipment.name = brand
    if brand.starts(with: "A") {
        equipment.checkCycle = 1
    }
    return equipment
}

#Preview {
    NavigationStack {
        List {
            EquipmentRow(equipment: equipment(for: "Unknown", type: .paraglider))
            EquipmentRow(equipment: equipment(for: "Unknown", type: .harness))
            EquipmentRow(equipment: equipment(for: "Unknown", type: .reserve))
            EquipmentRow(equipment: equipment(for: "Unknown", type: .gear))
            ForEach(Equipment.brandSuggestions, id: \.hashValue) { brand in
                EquipmentRow(equipment: equipment(for: brand))
            }
        }
    }
}
