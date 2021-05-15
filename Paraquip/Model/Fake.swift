//
//  Fake.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import Foundation

extension Profile {
    static func fake() -> Profile {
        Profile(
            name: "Equipment",
            equipment: [
                Paraglider(brand: Brand(name: "Gin", id: "gin"),
                           name: "Atlas 2",
                           size: "M",
                           checkCycle: 6,
                           checkLog: [
                            Check(date: Date(timeIntervalSinceNow: -10000))
                           ],
                           purchaseDate: Date(timeIntervalSinceNow: -1000000)),
                Paraglider(brand: Brand(name: "U-Turn", id: "u-turn"),
                           name: "Infinity 5",
                           size: "M",
                           checkCycle: 6,
                           checkLog: [
                            Check(date: Date(timeIntervalSinceNow: -160 * 60 * 60 * 24))
                           ]),
                Paraglider(brand: Brand(name: "Gin", id: "gin"),
                           name: "Explorer 2",
                           size: "S",
                           checkCycle: 12,
                           checkLog: [
                            Check(date: Date(timeIntervalSinceNow: -182 * 60 * 60 * 24))
                           ]),
                Harness(brand: Brand(name: "Gin", id: "gin"),
                        name: "Verso 3",
                        checkCycle: 12),
                Reserve(brand: Brand(name: "Gin", id: "gin"),
                        name: "Yeti",
                        checkCycle: 3)
            ])
    }
}
