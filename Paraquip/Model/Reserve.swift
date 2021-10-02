//
//  Reserve.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Reserve: Equipment, Identifiable {
    let id: UUID
    var brand: Brand
    var name: String
    var checkCycle: Int
    let checkLog: [Check]
    var purchaseDate: Date?

    init(id: UUID = UUID(), brand: Brand, name: String, checkCycle: Int, checkLog: [Check] = [], purchaseDate: Date? = nil) {
        self.id = id
        self.brand = brand
        self.name = name
        self.checkCycle = checkCycle
        self.checkLog = checkLog.sorted()
        self.purchaseDate = purchaseDate
    }
}

extension Reserve {
    init() {
        self.init(brand: .none, name: "", checkCycle: 3)
    }
}

extension ReserveModel {
    func toModel() -> Reserve {
        return Reserve(
            id: id!,
            brand: Brand(name: brand!, id: brandId),
            name: name!,
            checkCycle: Int(checkCycle),
            checkLog: (checkLog as! Set<CheckModel>).map { $0.toModel() },
            purchaseDate: purchaseDate
        )
    }
}
