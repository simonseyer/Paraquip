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

extension Profile: Creatable {
    enum Icon: String, CaseIterable, Identifiable {
        case campground, feather, mountain, beach, cloud, hiking, trophy, wind

        var id: String { rawValue }
        var systemName: String {
            switch self {
            case .campground: return "tent.fill"
            case .feather: return "backpack.fill"
            case .mountain: return "photo.fill"
            case .beach: return "beach.umbrella.fill"
            case .cloud: return "cloud.fill"
            case .hiking: return "figure.hiking"
            case .trophy: return "trophy.fill"
            case .wind: return "wind"
            }
        }

        static var `default`: Icon { .mountain }
    }
    
    var equipmentPredicate: NSPredicate {
        .init(format: "%@ IN %K", self, #keyPath(Equipment.profiles))
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
    
    var paraglider: Paraglider? {
        equipment?.first(where: { element in
            element is Paraglider
        }) as? Paraglider
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
    
    var wingLoad: Double? {
        guard let projectedArea = paraglider?.projectedAreaMeasurement else {
            return nil
        }
        let weightValue = takeoffWeightMeasurement.converted(to: .kilograms).value
        let projectedAreaValue = projectedArea.converted(to: .squareMeters).value
        return weightValue / projectedAreaValue
    }
}
