//
//  ReservePersistenceMapping.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

extension Reserve {
    func toPersistence() -> PersistedReserve {
        return PersistedReserve(
            id: id,
            brand: brand.name,
            brandId: brand.id,
            name: name,
            checkCycle: checkCycle,
            checkLog: checkLog.map { $0.toPersistence() }
        )
    }
}

extension PersistedReserve {
    func toModel() -> Reserve {
        return Reserve(
            id: id,
            brand: Brand(name: brand, id: brandId),
            name: name,
            checkCycle: checkCycle,
            checkLog: checkLog.map { $0.toModel() } )
    }
}
