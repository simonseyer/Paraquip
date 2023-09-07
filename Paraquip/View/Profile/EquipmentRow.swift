//
//  EquipmentRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import SwiftUI
import CoreData

extension Equipment.CheckUrgency {
    fileprivate var icon: some View {
        switch self {
        case .now, .soon:
            return Image(systemName: "exclamationmark")
                .font(.system(size: 13, weight: .heavy))
        case .later, .never:
            return Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
        }
    }
}

struct EquipmentRow: View {

    @ObservedObject var equipment: Equipment

    let onEdit: () -> Void
    let onDelete: () -> Void

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
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
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
                EquipmentRow(equipment: equipment(for: "Unknown", type: .paraglider), onEdit: {}, onDelete: {})
                EquipmentRow(equipment: equipment(for: "Unknown", type: .harness), onEdit: {}, onDelete: {})
                EquipmentRow(equipment: equipment(for: "Unknown", type: .reserve), onEdit: {}, onDelete: {})
                EquipmentRow(equipment: equipment(for: "Unknown", type: .gear), onEdit: {}, onDelete: {})
                ForEach(Equipment.brandSuggestions, id: \.hashValue) { brand in
                    EquipmentRow(equipment: equipment(for: brand), onEdit: {}, onDelete: {})
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
