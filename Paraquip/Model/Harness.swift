//
//  Harness.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import Foundation

struct Harness: Equipment, Identifiable {
    var id = UUID()
    var brand: Brand
    var name: String
    var checkCycle: Int
    var checkLog: [Check] = []
}

extension Harness {
    static func new() -> Harness {
        return Harness(brand: Brand(name: ""), name: "", checkCycle: 12)
    }
}
