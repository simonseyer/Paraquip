//
//  EditEquipmentViewModel.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.08.21.
//

import Foundation

enum BrandSelection {
    case known(_: Brand)
    case custom
    case none

    var isSelected: Bool {
        if case .none = self {
            return false
        }
        return true
    }
}

class EditEquipmentViewModel: ObservableObject {

    private let store: ProfileStore

    let isNew: Bool

    @Published var equipment: Equipment
    @Published var sizeIndex: Int = 4
    @Published var brandIndex: Int = 0
    @Published var customBrandName: String = ""
    @Published var checkCycle: Double = 12
    @Published var lastCheckDate: Date?
    @Published var manualURL: URL?

    let sizeOptions = ["XXS", "XS", "S", "SM", "M", "L", "XL", "XXL"]
    let brandOptions: [BrandSelection] = {
        return [.none, .custom] + Brand.allBrands.map { .known($0) }
    }()

    var brandSelection: BrandSelection {
        brandOptions[brandIndex]
    }

    var brand: Brand? {
        switch brandSelection {
        case .none:
            return nil
        case .custom:
            return Brand(name: customBrandName, id: nil)
        case .known(let selectedBrand):
            return selectedBrand
        }
    }

    init(store: ProfileStore, equipment: Equipment, isNew: Bool) {
        self.store = store
        self.equipment = equipment
        self.isNew = isNew

        if let brandId = equipment.brand.id {
            self.brandIndex = brandOptions.firstIndex { brandSelection in
                if case .known(let brand) = brandSelection {
                    return brand.id == brandId
                }
                return false
            } ?? 0
        } else if !equipment.brand.name.isEmpty {
            self.brandIndex = 1 // .custom
            self.customBrandName = equipment.brand.name
        }

        if let paraglider = equipment as? Paraglider {
            self.sizeIndex = sizeOptions.firstIndex(where: { (size) -> Bool in
                size == paraglider.size
            }) ?? 4
        }
        self.checkCycle = Double(equipment.checkCycle)
    }

    func save() {
        guard let brand = brand else {
            preconditionFailure("No brand selected")
        }

        equipment.brand = brand
        equipment.checkCycle = Int(checkCycle)

        if var paraglider = equipment as? Paraglider {
            paraglider.size = sizeOptions[sizeIndex]
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
