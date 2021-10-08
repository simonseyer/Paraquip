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

    static func create(context: NSManagedObjectContext) -> Profile {
        let profile = Profile(context: context)
        profile.id = UUID()
        return profile
    }
}
