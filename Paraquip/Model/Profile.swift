//
//  Profile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Profile: Identifiable {
    let id: UUID
    var name: String
    var icon: Icon
    let equipment: [Equipment]

    init(id: UUID = UUID(), name: String, icon: Icon, equipment: [Equipment] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.equipment = equipment.sorted()
    }
}

extension Profile {
    enum Icon: String, CaseIterable, Identifiable {
        case campground, feather, mountain, beach, cloud, hiking, trophy, wind

        var id: String { rawValue }

        static var `default`: Icon { .mountain }
    }
}

extension Array where Element == Equipment {
    func sorted() -> [Element] {
        return sorted { equipment1, equipment2 in
            // If check cycle for both equipment is turned off, sort by last check
            if equipment1.nextCheck == nil && equipment2.nextCheck == nil {

                // If no order inherent can be determined, keep order stable by id
                if equipment1.lastCheck == nil && equipment2.lastCheck == nil {
                    return equipment1.id.uuidString < equipment2.id.uuidString
                }

                // Equipment *without* a check at all goes first
                guard let lastCheck1 = equipment1.lastCheck else {
                    return true
                }
                guard let lastCheck2 = equipment2.lastCheck else {
                    return false
                }

                // Equipment with the oldest check goes first
                return lastCheck1 < lastCheck2
            }

            // Equipment *with* a next check goes first (equipment with disabled check cycle goes last)
            guard let nextCheck1 = equipment1.nextCheck else {
                return false
            }
            guard let nextCheck2 = equipment2.nextCheck else {
                return true
            }

            // Equipment with closest check goes first
            return nextCheck1 < nextCheck2
        }
    }
}

extension ProfileModel {
    func toModel() -> Profile {
        var equipment: [Equipment] = []
        equipment.append(contentsOf: (paraglider as! Set<ParagliderModel>).map { $0.toModel() })
        equipment.append(contentsOf: (reserves as! Set<ReserveModel>).map { $0.toModel() })
        equipment.append(contentsOf: (harnesses as! Set<HarnessModel>).map { $0.toModel() })

        return Profile(
            id: id!,
            name: name!,
            icon: Profile.Icon(rawValue: icon ?? "") ?? .default,
            equipment: equipment
        )
    }
}
