//
//  Harness.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import Foundation

struct Harness: Equipment, Identifiable {
    var id: UUID
    var brand: Brand
    var name: String
    var checkCycle: Int
    let checkLog: [Check]
    var purchaseDate: Date?

    internal init(id: UUID = UUID(), brand: Brand, name: String, checkCycle: Int, checkLog: [Check] = [], purchaseDate: Date? = nil) {
        self.id = id
        self.brand = brand
        self.name = name
        self.checkCycle = checkCycle
        self.checkLog = checkLog.sorted()
        self.purchaseDate = purchaseDate
    }
}

extension Harness {
    static func new() -> Harness {
        return Harness(brand: Brand(name: ""), name: "", checkCycle: 12)
    }
}

extension HarnessModel {
    func toModel() -> Harness {
        return Harness(
            id: id!,
            brand: Brand(name: brand!, id: brandId),
            name: name!,
            checkCycle: Int(checkCycle),
            checkLog: (checkLog as! Set<CheckModel>).map { $0.toModel() },
            purchaseDate: purchaseDate
        )
    }
}
