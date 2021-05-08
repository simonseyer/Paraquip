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
    var checkLog: [Check] = []
}

extension Paraglider {
    static func new() -> Paraglider {
        return Paraglider(brand: Brand(name: ""), name: "", size: "M", checkCycle: 6)
    }
}
