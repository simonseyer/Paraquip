//
//  Equipment.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension EquipmentModel {
    enum CheckUrgency {
        case now
        case soon(Date)
        case later(Date)
        case never
    }

    enum Size: String, CaseIterable, Identifiable {
        case none = ""
        case extraExtraSmall = "XXS"
        case extraSmall = "XS"
        case small = "S"
        case smallMedium = "SM"
        case medium = "M"
        case large = "L"
        case extraLarge = "XL"
        case extraExtraLarge = "XXL"

        var id: String { rawValue }
        
        static var allCases: [EquipmentModel.Size] {
            [.extraExtraSmall, .extraSmall, .small, .smallMedium, .medium, .large, .extraLarge, .extraExtraLarge]
        }
    }

    var equipmentName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var equipmentSize: EquipmentModel.Size {
        get { EquipmentModel.Size(rawValue: size ?? "") ?? .none }
        set { size = newValue.rawValue }
    }

    var floatingCheckCycle: Double {
        get { Double(checkCycle) }
        set { checkCycle = Int16(newValue) }
    }

    var equipmentBrand: Brand {
        get { Brand(name: brand, id: brandId) }
        set {
            brand = newValue.name
            brandId = newValue.id
        }
    }

    var brandName: String {
        get { brand ?? "" }
        set { brand = newValue }
    }

    var sortedCheckLog: [CheckModel] {
        return (checkLog as! Set<CheckModel>).sorted { check1, check2 in
            return check1.date! > check2.date!
        }
    }

    var lastCheck: Date? {
        sortedCheckLog.first?.date ?? purchaseDate
    }

    var nextCheck: Date? {
        guard checkCycle > 0 else {
            return nil
        }

        guard let lastCheck = lastCheck else {
            return Date.now
        }

        return Calendar.current.date(byAdding: .month,
                                     value: Int(checkCycle),
                                     to: lastCheck)!
    }

    var checkUrgency: CheckUrgency {
        guard let nextCheck = nextCheck else {
            return .never
        }

        let months = Calendar.current.dateComponents([.month], from: Date.now, to: nextCheck).month ?? 0

        if Calendar.current.isDate(nextCheck, inSameDayAs: Date.now) ||
            nextCheck < Date.now {
            return .now
        } else if months == 0 {
            return .soon(nextCheck)
        } else {
            return .later(nextCheck)
        }
    }

    static func create(context: NSManagedObjectContext) -> Self {
        let equipment = Self(context: context)
        equipment.id = UUID()
        return equipment
    }
}

extension CheckModel {
    static func create(context: NSManagedObjectContext, date: Date) -> Self {
        let check = Self(context: context)
        check.id = UUID()
        check.date = date
        return check
    }
}
