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

    var body: some View {
        if equipment.brandName.isEmpty && equipment.equipmentName.isEmpty {
            Text(equipment.equipmentType.localizedNameString)
        } else {
            VStack(alignment: .leading) {
                Text(equipment.equipmentName)
                Text(equipment.brandName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct EquipmentRow_Previews: PreviewProvider {

    static var previews: some View {
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

    private static func equipment(for brand: String, type: Equipment.EquipmentType = .reserve) -> Equipment {
        let equipment = Equipment.create(type: type, context: .preview)
        equipment.brandName = brand
        equipment.name = brand
        if brand.starts(with: "A") {
            equipment.checkCycle = 1
        }
        return equipment
    }
}
