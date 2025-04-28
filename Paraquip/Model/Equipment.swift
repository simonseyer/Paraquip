//
//  Equipment.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension Equipment {
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
    }

    enum CheckUrgency: Equatable {
        case now
        case soon(Date)
        case later(Date)
        case never
    }

    static let sizeSuggestions = ["XXS", "XS", "S", "SM", "M", "L", "XL", "XXL"] + (20...30).map { "\($0)" }

    static let brandSuggestions = [
        "Advance",
        "Air G",
        "Aeros",
        "Air Cross",
        "Airdesign",
        "Axis",
        "Basisrausch",
        "BGD",
        "Charly",
        "Dudek",
        "Fly Products",
        "Gin",
        "High Adventure",
        "Icaro",
        "Independence",
        "ITT",
        "ITV",
        "Mac Para",
        "Neo",
        "Nervures",
        "Nirvana",
        "Niviuk",
        "Nova",
        "NZ Aerosports",
        "Olympus",
        "Ozone",
        "Phi",
        "Pro design",
        "Sky Country",
        "Sky Paragliders",
        "Skyline",
        "Skywalk",
        "SOL Paragliders",
        "Squirrel",
        "Supair",
        "Swing",
        "Trekking Parapentes",
        "Triple Seven Gliders",
        "U-Turn",
        "Up",
        "Windtech",
        "Woody Valley"
    ]

    static let brandIdentifier = brandSuggestions.map { $0.slugified() }

    static func defaultSortDescriptors<T: Equipment>() -> [SortDescriptor<T>] {
        [
            SortDescriptor(\T.type),
            SortDescriptor(\T.brand),
            SortDescriptor(\T.name)
        ]
    }
    
    @MainActor static let defaultNSSortDescriptors = [
        NSSortDescriptor(key: "type", ascending: true),
        NSSortDescriptor(key: "brand", ascending: true),
        NSSortDescriptor(key: "name", ascending: true)
    ]

    var equipmentType: EquipmentType {
        EquipmentType(rawValue: type) ?? .paraglider
    }

    var equipmentID: UUID {
        id!
    }

    var equipmentName: String {
        get { name ?? "" }
        set {
            if name != newValue {
                objectWillChange.send()
                name = newValue
            }
        }
    }

    var equipmentSize: String {
        get { size ?? "" }
        set {
            if size != newValue {
                objectWillChange.send()
                size = newValue
            }
        }
    }

    var floatingCheckCycle: Double {
        get { Double(checkCycle) }
        set {
            if checkCycle != Int16(newValue) {
                objectWillChange.send()
                checkCycle = Int16(newValue)
            }
        }
    }

    var brandName: String {
        get { brand ?? "" }
        set {
            if brand != newValue {
                objectWillChange.send()
                brand = newValue
            }
        }
    }

    var weightMeasurement: Measurement<UnitMass>? {
        get {
            guard let weight = weight?.doubleValue else { return nil }
            return Measurement<UnitMass>(value: weight, unit: .baseUnit())
        }
        set {
            let newWeight = newValue.map { NSNumber(value: $0.converted(to: .baseUnit()).value) }
            if weight != newWeight {
                objectWillChange.send()
                weight = newWeight
            }
        }
    }

    var weightValue: Double? {
        get { weight?.doubleValue }
        set {
            let newWeight = newValue.map { NSNumber(value: $0) }
            if weight != newWeight {
                objectWillChange.send()
                weight = newWeight
            }
        }
    }

    var minWeightValue: Double? {
        get { minWeight?.doubleValue }
        set {
            let newWeight = newValue.map { NSNumber(value: $0) }
            if minWeight != newWeight {
                objectWillChange.send()
                minWeight = newWeight
            }
        }
    }

    var maxWeightValue: Double? {
        get { maxWeight?.doubleValue }
        set {
            let newWeight = newValue.map { NSNumber(value: $0) }
            if maxWeight != newWeight {
                objectWillChange.send()
                maxWeight = newWeight
            }
        }
    }

    var minRecommendedWeightValue: Double? {
        get { minRecommendedWeight?.doubleValue }
        set {
            let newWeight = newValue.map { NSNumber(value: $0) }
            if minRecommendedWeight != newWeight {
                objectWillChange.send()
                minRecommendedWeight = newWeight
            }
        }
    }

    var maxRecommendedWeightValue: Double? {
        get { maxRecommendedWeight?.doubleValue }
        set {
            let newWeight = newValue.map { NSNumber(value: $0) }
            if maxRecommendedWeight != newWeight {
                objectWillChange.send()
                maxRecommendedWeight = newWeight
            }
        }
    }

    var projectedAreaValue: Double? {
        get { projectedArea?.doubleValue }
        set {
            let newArea = newValue.map { NSNumber(value: $0) }
            if projectedArea != newArea {
                objectWillChange.send()
                projectedArea = newArea
            }
        }
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
    
    static func paraglider(context: NSManagedObjectContext) -> Equipment {
        return .create(.paraglider, context: context)
    }
    
    static func harness(context: NSManagedObjectContext) -> Equipment {
        return .create(.harness, context: context)
    }
    
    static func reserve(context: NSManagedObjectContext) -> Equipment {
        return .create(.reserve, context: context)
    }
    
    static func gear(context: NSManagedObjectContext) -> Equipment {
        return .create(.gear, context: context)
    }

    static func create(_ type: EquipmentType, context: NSManagedObjectContext) -> Equipment {
        let equipment = Equipment.init(context: context)
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
