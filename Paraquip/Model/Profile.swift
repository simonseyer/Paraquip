//
//  Profile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension Profile {
    enum Icon: String, CaseIterable, Identifiable {
        case campground, feather, mountain, beach, cloud, hiking, trophy, wind

        var id: String { rawValue }

        static var `default`: Icon { .mountain }
    }

    var uuid: CVarArg {
        id! as CVarArg
    }

    var profileName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var profileIcon: Profile.Icon {
        get { Profile.Icon(rawValue: icon ?? "") ?? .default }
        set { icon = newValue.rawValue }
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

    static func create(context: NSManagedObjectContext) -> Profile {
        let profile = Profile(context: context)
        profile.id = UUID()
        return profile
    }
}
