//
//  Profile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Profile: Identifiable {
    var id = UUID()
    var name: String
    var equipment: [Equipment] = []
}

extension Profile {
    func toPersistence() -> PersistedProfile {
        return PersistedProfile(
            id: id,
            name: name,
            paraglider: equipment.filter {$0 is Paraglider }.map { ($0 as! Paraglider).toPersistence() },
            reserves: equipment.filter {$0 is Reserve }.map { ($0 as! Reserve).toPersistence() }
        )
    }
}

extension PersistedProfile {
    func toModel() -> Profile {
        return Profile(id: id,
                       name: name,
                       equipment: paraglider.map { $0.toModel() } + reserves.map { $0.toModel() }
        )
    }
}
