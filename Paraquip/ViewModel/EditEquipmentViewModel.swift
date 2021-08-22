//
//  EditEquipmentViewModel.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.08.21.
//

import Foundation

extension Brand: Identifiable, Hashable {
    static func == (lhs: Brand, rhs: Brand) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Paraglider.Size: Identifiable {
    var id: String { rawValue }
}

class EditEquipmentViewModel: ObservableObject {

    private let store: ProfileStore

    let isNew: Bool

    @Published var equipment: Equipment
    @Published var paragliderSize: Paraglider.Size = .medium
    @Published var brand: Brand
    @Published var customBrandName: String = ""
    @Published var checkCycle: Double = 12
    @Published var lastCheckDate: Date?
    @Published var manualURL: URL?

    init(store: ProfileStore, equipment: Equipment, isNew: Bool) {
        self.store = store
        self.equipment = equipment
        self.isNew = isNew
        self.brand = equipment.brand
        self.customBrandName = equipment.brand.name

        if let paraglider = equipment as? Paraglider {
            self.paragliderSize = paraglider.size
        }

        self.checkCycle = Double(equipment.checkCycle)
    }

    func save() {
        if case .custom = brand {
            equipment.brand = .custom(name: customBrandName)
        } else if brand != .none {
            equipment.brand = brand
        } else {
            preconditionFailure("Missing brand selection")
        }

        equipment.checkCycle = Int(checkCycle)

        if var paraglider = equipment as? Paraglider {
            paraglider.size = paragliderSize
            store.store(equipment: paraglider)
        } else {
            store.store(equipment: equipment)
        }

        if let date = lastCheckDate {
            store.logCheck(at: date, for: equipment)
        }
        
        if let url = manualURL {
            do {
                let data = try Data(contentsOf: url)
                store.attach(manual: data, to: equipment)
            } catch {
                print(error)
            }
        }
    }
}
