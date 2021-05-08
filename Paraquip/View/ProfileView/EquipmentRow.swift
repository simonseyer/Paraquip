//
//  EquipmentRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import SwiftUI

struct EquipmentRow: View {

    let equipment: Equipment

    var body: some View {
        HStack {
            Group {
                if let icon = equipment.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "star")
                        .foregroundColor(Color(UIColor.systemGray3))
                        .font(.system(size: 32))
                }
            }
            .frame(width: 60, height: 80, alignment: .center)
            .padding([.trailing])

            VStack(alignment: .leading) {
                Text(equipment.name)
                    .font(.headline)
                Spacer()
                HStack {
                    Image(systemName: "text.badge.checkmark")

                    Text(equipment.formattedCheckInterval)

                }.foregroundColor(equipment.checkIntervalColor)
            }.padding([.top, .bottom])
        }
    }
}

struct EquipmentRow_Previews: PreviewProvider {

    static var brands: [Brand] {
        Brand.allBrands + [Brand(name: "Unknown", id: nil)]
    }

    static var previews: some View {
        List {
            ForEach(brands, id: \.name) { brand in
                EquipmentRow(equipment: Reserve(brand: brand,
                                                name: brand.name,
                                                checkCycle: 6))
            }

        }.previewLayout(.fixed(width: 400, height: 4000))
    }
}