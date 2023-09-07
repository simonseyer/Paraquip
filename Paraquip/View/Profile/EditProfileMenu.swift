//
//  EditProfileMenu.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.03.23.
//

import SwiftUI

struct EditProfileMenu: View {

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
                        Text("Create new \(Text(type.localizedName))")
                    } icon: {
                        type.iconImage
                    }
                }
            }
            if canEditProfile {
                Divider()
                Button(action: onEditProfile) {
                    Label("Edit set", systemImage: "pencil")
                }
            }
        } label: {
            Text("Edit")
        }
        .controlSize(.small)
        .buttonStyle(.bordered)
    }
}


struct AddEquipmentMenu_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileMenu(canEditProfile: true,
                         onAddEquipment:{_ in },
                         onEditProfile: {})
    }
}
