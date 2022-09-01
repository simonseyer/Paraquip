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
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(UIColor.systemGray3))
                        .font(.system(size: 24))
                }
            }
            .frame(width: 70, height: 50, alignment: .center)
            .padding(.trailing, 12)

            HStack {
                Text(equipment.equipmentName)
                Spacer()
                equipment.checkUrgency.icon
                    .foregroundColor(equipment.checkUrgency.color)
            }
            .padding([.top, .bottom], 25)
        }
    }
}

struct EquipmentRow_Previews: PreviewProvider {

    static var previews: some View {
        List {
            ForEach(Equipment.brandSuggestions, id: \.hashValue) { brand in
                EquipmentRow(equipment: equipment(for: brand))
            }
        }
    }

    private static func equipment(for brand: String) -> Equipment {
        let equipment = Reserve.create(context: CoreData.previewContext)
        equipment.brandName = brand
        equipment.name = brand
        return equipment
    }
}
