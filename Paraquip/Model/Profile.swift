//
//  Profile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData

extension ProfileModel {
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

    var profileIcon: ProfileModel.Icon {
        get { ProfileModel.Icon(rawValue: icon ?? "") ?? .default }
        set { icon = newValue.rawValue }
    }

    static func create(context: NSManagedObjectContext) -> ProfileModel {
        let profile = ProfileModel(context: context)
        profile.id = UUID()
        return profile
    }
}
