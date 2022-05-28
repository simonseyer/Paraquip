//
//  Equipment.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension Equipment: Creatable {
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
        
        static var allCases: [Equipment.Size] {
            [.extraExtraSmall, .extraSmall, .small, .smallMedium, .medium, .large, .extraLarge, .extraExtraLarge]
        }
    }

    var equipmentName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var equipmentSize: Equipment.Size {
        get { Equipment.Size(rawValue: size ?? "") ?? .none }
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

    var weightMeasurement: Measurement<UnitMass>? {
        get {
            guard let weight = weight?.doubleValue else { return nil }
            return Measurement<UnitMass>(value: weight, unit: .baseUnit())
        }
        set {
            guard let weightMeasurement = newValue else { weight = nil; return }
            weight = NSNumber(value: weightMeasurement.converted(to: .baseUnit()).value)
        }
    }

    var weightRangeMeasurement: ClosedRange<Measurement<UnitMass>>? {
        get {
            guard let weightRange = weightRange else { return nil }
            let min = Measurement<UnitMass>(value: weightRange.min, unit: .baseUnit())
            let max = Measurement<UnitMass>(value: weightRange.max, unit: .baseUnit())
            return ClosedRange(uncheckedBounds: (min, max))
        }
        set {
            guard let weightRange = newValue else {
                if let oldWeightRange = weightRange {
                    managedObjectContext?.delete(oldWeightRange)
                }
                return
            }
            let range = WeightRange(context: managedObjectContext!)
            range.min = weightRange.lowerBound.converted(to: .baseUnit()).value
            range.max = weightRange.upperBound.converted(to: .baseUnit()).value
            self.weightRange = range
        }
    }

    var allChecks: Set<LogEntry> {
        checkLog as! Set<LogEntry>
    }

    var lastCheck: Date? {
        // TODO: not performant
        allChecks.sorted { check1, check2 in
            return check1.date! > check2.date!
        }.first?.date ?? purchaseLog?.date
    }

    var nextCheck: Date? {
        guard checkCycle > 0 else {
            return nil
        }

        guard let lastCheck = lastCheck else {
            return Date.paraquipNow
        }

        return Calendar.current.date(byAdding: .month,
                                     value: Int(checkCycle),
                                     to: lastCheck)!
    }

    var checkUrgency: CheckUrgency {
        guard let nextCheck = nextCheck else {
            return .never
        }

        let months = Calendar.current.dateComponents([.month], from: Date.paraquipNow, to: nextCheck).month ?? 0

        if Calendar.current.isDate(nextCheck, inSameDayAs: Date.paraquipNow) ||
            nextCheck < Date.paraquipNow {
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
