//
//  Profile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension Measurement where UnitType == UnitMass {
    static var zero: Self {
        .init(value: 0, unit: .baseUnit())
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

class AllEquipmentProfile: Profile {
    override var name: String? {
        get { String(localized: "All Equipment") }
        set {}
    }

    static var shared: AllEquipmentProfile { .init() }
}

extension Profile {
    enum Icon: String, CaseIterable, Identifiable {
        case campground, feather, mountain, beach, cloud, hiking, trophy, wind

        var id: String { rawValue }
        var systemName: String {
            switch self {
            case .campground: return "tent"
            case .feather: return "backpack"
            case .mountain: return "mountain.2"
            case .beach: return "beach.umbrella"
            case .cloud: return "cloud"
            case .hiking: return "figure.hiking"
            case .trophy: return "trophy"
            case .wind: return "wind"
            }
        }

        static var `default`: Icon { .mountain }
    }

    var isAllEquipment: Bool {
        self is AllEquipmentProfile
    }

    var equipmentPredicate: NSPredicate {
        if (isAllEquipment) {
            NSPredicate(value: true)
        } else {
            NSPredicate(format: "%@ IN %K", self, #keyPath(Equipment.profiles))
        }
    }

    var profileName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var profileIcon: Profile.Icon {
        get { Profile.Icon(rawValue: icon ?? "") ?? .default }
        set { icon = newValue.rawValue }
    }

    var pilotWeightMeasurement: Measurement<UnitMass> {
        get {
            return Measurement<UnitMass>(value: pilotWeight, unit: .baseUnit())
        }
        set {
            pilotWeight = newValue.converted(to: .baseUnit()).value
        }
    }

    var additionalWeightMeasurement: Measurement<UnitMass> {
        get {
            return Measurement<UnitMass>(value: additionalWeight, unit: .baseUnit())
        }
        set {
            additionalWeight = newValue.converted(to: .baseUnit()).value
        }
    }

    var allEquipment: [Equipment] {
        let set = equipment as? Set<Equipment> ?? []
        return Array<Equipment>(set).sorted { $0.equipmentName > $1.equipmentName }
    }
    
    var paraglider: Equipment? {
        allEquipment.first { $0.equipmentType == .paraglider }
    }

    func singleEquipment(of type: Equipment.EquipmentType) -> Equipment? {
        allEquipment.first { $0.equipmentType == type }
    }

    static func create(context: NSManagedObjectContext, name: String) -> Self {
        let profile = Self(context: context)
        profile.id = UUID()
        profile.name = name
        return profile
    }

    static func create(context: NSManagedObjectContext) -> Self {
        return create(context: context, name: "")
    }

    func contains(_ equipment: Equipment) -> Bool {
        self.equipment?.contains(equipment) ?? false
    }

    func toggle(_ equipment: Equipment) {
        if contains(equipment) {
            removeFromEquipment(equipment)
        } else {
            if [.paraglider, .harness].contains(equipment.equipmentType) {
                for equipment in self.allEquipment.filter({ $0.equipmentType == equipment.equipmentType }) {
                    removeFromEquipment(equipment)
                }
            }
            addToEquipment(equipment)
        }
    }
    
    var equipmentWeightMeasurement: Measurement<UnitMass> {
        allEquipment.compactMap { $0.weightMeasurement }.reduce(.zero, +)
    }
    
    var takeoffWeightMeasurement: Measurement<UnitMass> {
        equipmentWeightMeasurement + pilotWeightMeasurement + additionalWeightMeasurement
    }

    var wingLoadValue: Double? {
        guard !takeoffWeightMeasurement.value.isZero else { return nil }
        return wingLoad(weight: takeoffWeightMeasurement.converted(to: .kilograms).value)
    }

    var desiredWingLoadValue: Double {
        get {
            if let desiredWingLoad {
                // Clamp to exentededRange to make sure it does not exceed it when weight range changes
                return desiredWingLoad.doubleValue.clamped(to: visualizedWingLoadRange)
            } else if let min = paraglider?.minWeightValue,
                      let max = paraglider?.maxWeightValue,
                      let wingLoad = wingLoad(weight: (min + max) / 2.0) {
                return wingLoad
            } else {
                return (visualizedWingLoadRange.lowerBound + visualizedWingLoadRange.upperBound) / 2.0
            }
        }
        set { desiredWingLoad = .init(value: newValue) }
    }

    var visualizedWingLoadRange: ClosedRange<Double> {
        let buffer = 0.1
        let defaultLower = 3.8
        let defaultUpper = 4.9

        var lower = wingLoad(weight: paraglider?.minWeightValue) ?? defaultLower
        var upper = wingLoad(weight: paraglider?.maxWeightValue) ?? defaultUpper

        if let wingLoadValue {
            lower = min(lower, wingLoadValue)
            upper = max(upper, wingLoadValue)
        }

        lower = min(defaultLower, lower - buffer).rounded(digits: 1, rule: .down)
        upper = max(defaultUpper, upper + buffer).rounded(digits: 1, rule: .up)

        return lower...upper
    }

    var visualizedWeightRange: ClosedRange<Double>? {
        guard let projectedArea = paraglider?.projectedArea?.doubleValue else {
            return nil
        }
        return (visualizedWingLoadRange.lowerBound * projectedArea)...(visualizedWingLoadRange.upperBound * projectedArea)
    }

    private func wingLoad(weight: Double?) -> Double? {
        guard let weight, let projectedArea = paraglider?.projectedArea?.doubleValue else {
            return nil
        }
        return weight / projectedArea
    }
}
