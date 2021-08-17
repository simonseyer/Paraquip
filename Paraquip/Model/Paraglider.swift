//
//  Paraglider.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Paraglider: Equipment, Identifiable {
    var id = UUID()
    var brand: Brand
    var name: String
    var size: String
    var checkCycle: Int
    let checkLog: [Check]
    var purchaseDate: Date?

    init(id: UUID = UUID(), brand: Brand, name: String, size: String, checkCycle: Int, checkLog: [Check] = [], purchaseDate: Date? = nil) {
        self.id = id
        self.brand = brand
        self.name = name
        self.size = size
        self.checkCycle = checkCycle
        self.checkLog = checkLog.sorted()
        self.purchaseDate = purchaseDate
    }
}

extension Paraglider {
    static func new() -> Paraglider {
        return Paraglider(brand: Brand(name: ""), name: "", size: "M", checkCycle: 6)
    }
}

extension ParagliderModel {
    func toModel() -> Paraglider {
        return Paraglider(
            id: id!,
            brand: Brand(name: brand!, id: brandId),
            name: name!,
            size: size!,
            checkCycle: Int(checkCycle),
            checkLog: (checkLog as! Set<CheckModel>).map { $0.toModel() },
            purchaseDate: purchaseDate
        )
    }
}
