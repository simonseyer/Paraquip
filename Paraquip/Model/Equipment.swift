//
//  Equipment.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension Equipment: Creatable {
    enum ValidationError: Error {
        case invalidWeightRanges
    }

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

    static func defaultSortDescriptors<T: Equipment>() -> [SortDescriptor<T>] {
        [
            SortDescriptor(\T.type),
            SortDescriptor(\T.brand),
            SortDescriptor(\T.name)
        ]
    }
    
    static let defaultNSSortDescriptors = [
        NSSortDescriptor(key: "type", ascending: true),
        NSSortDescriptor(key: "brand", ascending: true),
        NSSortDescriptor(key: "name", ascending: true)
    ]
    
    static var previewEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: .preview)!
    }

    var equipmentType: EquipmentType {
        EquipmentType(rawValue: type) ?? .paraglider
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

    var weightValue: Double? {
        get { weight?.doubleValue }
        set { weight = .init(value: newValue) }
    }

    var minWeightValue: Double? {
        get { minWeight?.doubleValue }
        set { minWeight = .init(value: newValue)}
    }

    var maxWeightValue: Double? {
        get { maxWeight?.doubleValue }
        set { maxWeight = .init(value: newValue) }
    }

    var minRecommendedWeightValue: Double? {
        get { minRecommendedWeight?.doubleValue }
        set { minRecommendedWeight = .init(value: newValue) }
    }

    var maxRecommendedWeightValue: Double? {
        get { maxRecommendedWeight?.doubleValue }
        set { maxRecommendedWeight = .init(value: newValue) }
    }

    var projectedAreaValue: Double? {
        get { projectedArea?.doubleValue }
        set { projectedArea = .init(value: newValue) }
    }

    var weightRanges: [Double] {
        [
            minWeightValue,
            minRecommendedWeightValue,
            maxRecommendedWeightValue,
            maxWeightValue
        ].compactMap { $0 }
    }

    var hasRecommendedWeightRange: Bool {
        minRecommendedWeight != nil || maxRecommendedWeight != nil
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

    func clearRecommendedWeightRange() {
        minRecommendedWeight = nil
        maxRecommendedWeight = nil
    }

    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateWeightRanges()
    }

    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateWeightRanges()
    }

    private func validateWeightRanges() throws {
        if weightRanges.sorted() != weightRanges {
            throw ValidationError.invalidWeightRanges
        }
    }
}
