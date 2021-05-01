//
//  Paraglider.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Paraglider: Equipment, Identifiable {
    var id = UUID()
    var brand: String
    var name: String
    var size: String
    var checkCycle: Int
    var checkLog: [Check] = []
}

extension Paraglider {
    func toPersistence() -> PersistedParaglider {
        return PersistedParaglider(
            id: id,
            brand: brand,
            name: name,
            size: size,
            checkCycle: checkCycle,
            checkLog: checkLog.map { $0.toPersistence() }
        )
    }
}

extension PersistedParaglider {
    func toModel() -> Paraglider {
        return Paraglider(
            id: id,
            brand: brand,
            name: name,
            size: size,
            checkCycle: checkCycle,
            checkLog: checkLog.map { $0.toModel() } )
    }
}

extension Paraglider {
    static func new() -> Paraglider {
        return Paraglider(brand: "", name: "", size: "M", checkCycle: 6)
    }
}
