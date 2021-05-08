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
        NavigationLink(destination: EquipmentView(equipmentId: equipment.id)) {
            HStack {
                equipment.icon
                    .resizable()
                    .scaledToFit()
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
}

struct EquipmentRow_Previews: PreviewProvider {
    static var previews: some View {
        EquipmentRow(equipment: Profile.fake().equipment.first!)
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
