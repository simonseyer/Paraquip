//
//  Equipment.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension Equipment: Creatable {
    enum EquipmentType: Int16, CaseIterable, Identifiable {
        case paraglider = 1
        case harness = 2
        case reserve = 3
        case gear = 4

        var id: Int16 {
            rawValue
        }

        static func type(for equipment: Equipment) -> Self {
            switch equipment {
            case is Paraglider:
                return .paraglider
            case is Harness:
                return .harness
            case is Reserve:
                return .reserve
            case is Gear:
                return .gear
            default:
                fatalError("Unknown equipment type: \(Swift.type(of: equipment))")
            }
        }
    }

    enum CheckUrgency {
        case now
        case soon(Date)
        case later(Date)
        case never
    }

    static let sizeSuggestions = ["XXS", "XS", "S", "SM", "M", "L", "XL", "XXL"] + (20...30).map { "\($0)" }

    static let brandSuggestions = ["Advance", "Air G", "Aeros", "Air Cross", "Airdesign", "Axis", "Basisrausch", "BGD", "Charly", "Dudek", "Fly Products", "Gin", "Icaro", "Independence", "ITT", "ITV", "Mac Para", "Neo", "Nervures", "Nirvana", "Niviuk", "Nova", "NZ Aerosports", "Olympus", "Ozone", "Phi", "Pro design", "Sky Country", "Sky Paragliders", "Skyline", "Skywalk", "SOL Paragliders", "Squirrel", "Supair", "Swing", "Trekking Parapentes", "Triple Seven Gliders", "U-Turn", "Up", "Windtech", "Woody Valley"]

    static let brandIdentifier = brandSuggestions.map { $0.slugified() }

    var equipmentType: EquipmentType {
        EquipmentType(rawValue: type)!
    }

    var equipmentName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var equipmentSize: String {
        get { size ?? "" }
        set { size = newValue }
    }

    var floatingCheckCycle: Double {
        get { Double(checkCycle) }
        set { checkCycle = Int16(newValue) }
    }

    var isCheckable: Bool {
        switch equipmentType {
        case .paraglider, .harness, .reserve: return true
        case .gear: return false
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
    
    var projectedAreaMeasurement: Measurement<UnitArea>? {
        get {
            guard let projectedArea = projectedArea?.doubleValue else { return nil }
            return Measurement<UnitArea>(value: projectedArea, unit: .baseUnit())
        }
        set {
            guard let projectedAreaMeasurement = newValue else { projectedArea = nil; return }
            projectedArea = NSNumber(value: projectedAreaMeasurement.converted(to: .baseUnit()).value)
        }
    }

    var weightRangeMeasurement: ClosedRange<Measurement<UnitMass>>? {
        get {
            guard let weightRange else { return nil }
            let min = Measurement<UnitMass>(value: weightRange.min, unit: .baseUnit())
            let max = Measurement<UnitMass>(value: weightRange.max, unit: .baseUnit())
            return ClosedRange(uncheckedBounds: (min, max))
        }
        set {
            guard let newValue else {
                if let weightRange {
                    managedObjectContext?.delete(weightRange)
                }
                return
            }
            let range = WeightRange(context: managedObjectContext!)
            range.min = newValue.lowerBound.converted(to: .baseUnit()).value
            range.max = newValue.upperBound.converted(to: .baseUnit()).value
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

        guard let lastCheck else {
            return Date.paraquipNow
        }

        return Calendar.current.date(byAdding: .month,
                                     value: Int(checkCycle),
                                     to: lastCheck)!
    }

    var checkUrgency: CheckUrgency {
        guard let nextCheck else {
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
        equipment.type = EquipmentType.type(for: equipment).rawValue
        return equipment
    }

    static func create(type: EquipmentType, context: NSManagedObjectContext) -> Equipment {
        let classType: Equipment.Type = {
            switch type {
            case .paraglider: return Paraglider.self
            case .harness: return Harness.self
            case .reserve: return Reserve.self
            case .gear: return Gear.self
            }
        }()
        let equipment = classType.init(context: context)
        equipment.id = UUID()
        equipment.type = type.rawValue
        return equipment
    }
}
