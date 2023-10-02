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
        VStack(alignment: .leading) {
            Text(equipmentName)
            Text(brandName)
                .font(.caption)
                .foregroundStyle(.secondary)
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
