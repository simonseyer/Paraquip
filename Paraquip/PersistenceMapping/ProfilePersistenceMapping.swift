//
//  ProfilePersistenceMapping.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

extension Profile {
    func toPersistence() -> PersistedProfile {
        return PersistedProfile(
            id: id,
            name: name,
            paraglider: equipment.lazy.filter(by: Paraglider.self).map { $0.toPersistence() },
            reserves: equipment.lazy.filter(by: Reserve.self).map { $0.toPersistence() }
        )
    }
}

extension Collection {
    func filter<T>(by: T.Type) -> [T] {
        return self
            .filter { $0 is T }
            .map { $0 as! T }
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
