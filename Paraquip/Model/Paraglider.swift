//
//  Paraglider.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Paraglider: Equipment, Identifiable {

    enum Size: String, CaseIterable {
        case extraExtraSmall = "XXS"
        case extraSmall = "XS"
        case small = "S"
        case smallMedium = "SM"
        case medium = "M"
        case large = "L"
        case extraLarge = "XL"
        case extraExtraLarge = "XXL"
    }

    var id = UUID()
    var brand: Brand
    var name: String
    var size: Size
    var checkCycle: Int
    let checkLog: [Check]
    var purchaseDate: Date?

    init(id: UUID = UUID(), brand: Brand, name: String, size: Size, checkCycle: Int, checkLog: [Check] = [], purchaseDate: Date? = nil) {
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
        return Paraglider(brand: .none, name: "", size: .medium, checkCycle: 6)
    }
}

extension ParagliderModel {
    func toModel() -> Paraglider {
        return Paraglider(
            id: id!,
            brand: Brand(name: brand!, id: brandId),
            name: name!,
            size: .init(rawValue: size!)!,
            checkCycle: Int(checkCycle),
            checkLog: (checkLog as! Set<CheckModel>).map { $0.toModel() },
            purchaseDate: purchaseDate
        )
    }
}
