//
//  Reserve.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Reserve: Equipment, Identifiable {
    var id = UUID()
    var brand: Brand
    var name: String
    var checkCycle: Int
    var checkLog: [Check] = []
    var purchaseDate: Date? = nil
}

extension Reserve {
    static func new() -> Reserve {
        return Reserve(brand: Brand(name: ""), name: "", checkCycle: 3)
    }
}
