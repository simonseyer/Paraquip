//
//  EquipmentRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import SwiftUI

struct EquipmentRow: View {

    let equipment: Equipment
    @Environment(\.locale) var locale

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
            .frame(width: 50, height: 50, alignment: .center)
            .padding(.trailing, 12)

            HStack {
                Text(equipment.name)
                Spacer()
                equipment.checkUrgency.icon
                    .foregroundColor(equipment.checkUrgency.color)
            }
            .padding([.top, .bottom], 25)
        }
    }
}

extension CheckUrgency {
    var icon: Image {
        switch self {
        case .now:
            return Image(systemName: "exclamationmark.circle.fill")
        case .soon:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .later:
            return Image(systemName: "checkmark.circle.fill")
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
