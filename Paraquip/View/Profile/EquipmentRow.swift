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

    @State private var deleteEquipment: Equipment?
    @State private var isDeletingEquipment = false

    let onEdit: () -> Void
    let onDelete: () -> Void
    let onRemoveFromSet: () -> Void

    var body: some View {
        NavigationLink(value: equipment) {
            HStack {
                Group {
                    if let icon = equipment.icon {
                        BrandIconView(image: icon, area: 1500, alignment: .center)
                    } else {
                        equipment.equipmentType.iconImage
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                            .opacity(0.5)
                            .foregroundColor(.accentColor)
                    }
                }
                .frame(width: 60, height: 36, alignment: .center)
                .padding(.trailing, 8)

                HStack {
                    Text(equipment.equipmentName)
                    Spacer()
                    equipment.checkUrgency.icon
                        .frame(width: 34, height: 24)
                        .foregroundStyle(.white)
                        .background(
                            Capsule().fill(equipment.checkUrgency.color)
                        )
                }
            }
        }
        .confirmationDialog(Text("Delete equipment"), isPresented: $isDeletingEquipment, presenting: deleteEquipment) { equipment in
            Button("Delete", role: .destructive, action: onDelete)
            Button("Remove from set", action: onRemoveFromSet)
            Button("Cancel", role: .cancel) {}
        }
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                deleteEquipment = equipment
                isDeletingEquipment = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct EquipmentRow_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            List {
                EquipmentRow(equipment: equipment(for: "Unknown", type: .paraglider), onEdit: {}, onDelete: {}, onRemoveFromSet: {})
                EquipmentRow(equipment: equipment(for: "Unknown", type: .harness), onEdit: {}, onDelete: {}, onRemoveFromSet: {})
                EquipmentRow(equipment: equipment(for: "Unknown", type: .reserve), onEdit: {}, onDelete: {}, onRemoveFromSet: {})
                EquipmentRow(equipment: equipment(for: "Unknown", type: .gear), onEdit: {}, onDelete: {}, onRemoveFromSet: {})
                ForEach(Equipment.brandSuggestions, id: \.hashValue) { brand in
                    EquipmentRow(equipment: equipment(for: brand), onEdit: {}, onDelete: {}, onRemoveFromSet: {})
                }
            }
            .environment(\.defaultMinListRowHeight, 10)
        }
    }

    private static func equipment(for brand: String, type: Equipment.EquipmentType = .reserve) -> Equipment {
        let equipment = Equipment.create(type: type, context: .preview)
        equipment.brandName = brand
        equipment.name = brand
        if brand.starts(with: "A") {
            equipment.checkCycle = 1
        }
        return equipment
    }
}
