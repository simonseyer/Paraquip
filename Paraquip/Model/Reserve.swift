//
//  Reserve.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Reserve: Equipment, Identifiable {
    var id = UUID()
    var brand: String
    var name: String
    var checkCycle: Int
    var checkLog: [Check] = []
}

extension Reserve {
    static func new() -> Reserve {
        return Reserve(brand: "", name: "", checkCycle: 3)
    }
}
