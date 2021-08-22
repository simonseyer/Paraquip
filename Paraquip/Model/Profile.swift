//
//  Profile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Profile: Identifiable {
    var id: UUID
    var name: String
    let equipment: [Equipment]

    init(id: UUID = UUID(), name: String, equipment: [Equipment] = []) {
        self.id = id
        self.name = name
        self.equipment = equipment.sorted()
    }
}

extension Array where Element == Equipment {
    func sorted() -> [Element] {
        return sorted { equipment1, equipment2 in
            guard let nextCheck1 = equipment1.nextCheck else {
                return false
            }
            
            guard let nextCheck2 = equipment2.nextCheck else {
                return true
            }

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

        return Profile(id: id!, name: name!, equipment: equipment)
    }
}
