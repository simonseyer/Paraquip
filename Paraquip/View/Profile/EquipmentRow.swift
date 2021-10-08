//
//  EquipmentRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import SwiftUI
import CoreData

struct EquipmentRow: View {

    @ObservedObject var equipment: EquipmentModel
    @Environment(\.locale) var locale

    var body: some View {
        HStack {
            Group {
                if let icon = equipment.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(UIColor.systemGray3))
                        .font(.system(size: 24))
                }
            }
            .frame(width: 50, height: 50, alignment: .center)
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

    static var brands: [Brand] {
        Brand.allCases
    }

    static let persistentContainer = NSPersistentContainer.fake(name: "Model")

    static var previews: some View {
        List {
            ForEach(Brand.allCases) { brand in
                EquipmentRow(equipment: equipment(for: brand))
            }
        }
    }

    private static func equipment(for brand: Brand) -> EquipmentModel {
        let equipment = ReserveModel.create(context: persistentContainer.viewContext)
        equipment.equipmentBrand = brand
        equipment.name = brand.name
        return equipment
    }
}
