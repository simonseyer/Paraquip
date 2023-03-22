//
//  AddEquipmentMenu.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.03.23.
//

import SwiftUI

struct AddEquipmentMenu: View {

    let canEditProfile: Bool
    let onAddEquipment: (Equipment.EquipmentType) -> Void
    let onEditProfile: () -> Void

    var body: some View {
        Menu {
            ForEach([Equipment.EquipmentType.reserve, Equipment.EquipmentType.gear]) { type in
                Button(action: {
                    onAddEquipment(type)
                }) {
                    Label {
                        Text(type.localizedName)
                    } icon: {
                        type.iconImage
                    }
                }
            }
            if canEditProfile {
                Divider()
                Button(action: onEditProfile) {
                    Label("Edit", systemImage: "slider.vertical.3")
                }
            }
        } label: {
            Image(systemName: "plus")
        }
    }
}


struct AddEquipmentMenu_Previews: PreviewProvider {
    static var previews: some View {
        AddEquipmentMenu(canEditProfile: true,
                         onAddEquipment:{_ in },
                         onEditProfile: {})
    }
}
