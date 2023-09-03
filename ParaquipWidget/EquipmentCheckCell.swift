//
//  EquipmentCheckCell.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.08.23.
//

import SwiftUI
import WidgetKit

struct EquipmentCheck: Identifiable {
    var equipmentName: String
    var equipmentType: Equipment.EquipmentType
    var date: Date

    var id: String {
        equipmentName + date.description
    }
}

struct EquipmentCheckCell: View {

    let check: EquipmentCheck

    var body: some View {
        Button(action: {}) {

            ProgressView(value: 0.5) {
                check.equipmentType.iconImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 22, height: 22)
                    .foregroundStyle(.regularMaterial)
            }.progressViewStyle(.circular)
                .frame(width: 30, height: 30)
                .tint(Material.ultraThin)

//            check.equipmentType.iconImage
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 22, height: 22)
//                .foregroundStyle(.regularMaterial)
//                .padding(.trailing, 2)
            VStack(alignment: .leading)  {
                Text(check.equipmentName)
                    .font(.subheadline)
                    .foregroundStyle(.ultraThickMaterial)

                // show relative date (only days)
                HStack {
                    Text("in")
                    Text(check.date, style: .relative)
                }
                .font(.caption)
                .foregroundStyle(.regularMaterial)

            }
            Spacer()
        }.buttonStyle(.plain)
    }
}

struct EquipmentCheckCell_Previews: PreviewProvider {
    static var previews: some View {
        EquipmentCheckCell(check: .init(equipmentName: "Explorer 2", equipmentType: .paraglider, date: Calendar.current.date(byAdding: .day, value: 20, to: Date())!))
            .containerBackground(.accent, for: .widget)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
