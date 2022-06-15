//
//  Profile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension Profile: Creatable {
    enum Icon: String, CaseIterable, Identifiable {
        case campground, feather, mountain, beach, cloud, hiking, trophy, wind

        var id: String { rawValue }
        var systemName: String {
            switch self {
            case .campground: return "tent"
            case .feather: return "backpack"
            case .mountain: return "photo"
            case .beach: return "beach.umbrella"
            case .cloud: return "cloud"
            case .hiking: return "figure.hiking"
            case .trophy: return "trophy"
            case .wind: return "wind"
            }
        }

        static var `default`: Icon { .mountain }
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

    var paraglider: [Paraglider] {
        allEquipment.compactMap { $0 as? Paraglider }
    }

    var harnesses: [Harness] {
        allEquipment.compactMap { $0 as? Harness }
    }

    var reserves: [Reserve] {
        allEquipment.compactMap { $0 as? Reserve }
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
}
