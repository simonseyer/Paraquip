//
//  HarnessPersistenceMapping.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import Foundation

extension Harness {
    func toPersistence() -> PersistedHarness {
        return PersistedHarness(
            id: id,
            brand: brand.name,
            brandId: brand.id,
            name: name,
            checkCycle: checkCycle,
            checkLog: checkLog.map { $0.toPersistence() }
        )
    }
}

extension PersistedHarness {
    func toModel() -> Harness {
        return Harness(
            id: id,
            brand: Brand(name: brand, id: brandId),
            name: name,
            checkCycle: checkCycle,
            checkLog: checkLog.map { $0.toModel() } )
    }
}
