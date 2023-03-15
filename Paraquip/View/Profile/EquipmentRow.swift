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
    @Environment(\.locale) var locale

    var body: some View {
        HStack {
            Group {
                if let icon = equipment.icon {
                    BrandIconView(image: icon, area: 1500, alignment: .center)
                } else {
                    equipment.equipmentType.iconImage
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .opacity(0.4)
                        .foregroundColor(.accentColor)
                }
            }
            .frame(width: 70, height: 50, alignment: .center)
            .padding(.trailing, 8)

            HStack {
                Text(equipment.equipmentName)
                Spacer()
                equipment.checkUrgency.icon
                    .foregroundColor(equipment.checkUrgency.color)
            }
        }
    }
}

struct EquipmentRow_Previews: PreviewProvider {

    static var previews: some View {
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

    private static func equipment(for brand: String, type: Equipment.EquipmentType = .reserve) -> Equipment {
        let equipment = Equipment.create(type: type, context: CoreData.previewContext)
        equipment.brandName = brand
        equipment.name = brand
        return equipment
    }
}
