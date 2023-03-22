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

    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        NavigationLink {
            EquipmentView(equipment: equipment)
        } label: {
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
        .swipeActions {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "slider.vertical.3")
            }
            .tint(.blue)

            Button {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .labelStyle(.titleOnly)
    }
}

struct EquipmentRow_Previews: PreviewProvider {

    static var previews: some View {
        List {
            EquipmentRow(equipment: equipment(for: "Unknown", type: .paraglider), onEdit: {}, onDelete: {})
            EquipmentRow(equipment: equipment(for: "Unknown", type: .harness), onEdit: {}, onDelete: {})
            EquipmentRow(equipment: equipment(for: "Unknown", type: .reserve), onEdit: {}, onDelete: {})
            EquipmentRow(equipment: equipment(for: "Unknown", type: .gear), onEdit: {}, onDelete: {})
            ForEach(Equipment.brandSuggestions, id: \.hashValue) { brand in
                EquipmentRow(equipment: equipment(for: brand), onEdit: {}, onDelete: {})
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
