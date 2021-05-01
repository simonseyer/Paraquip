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
                Paraglider(brand: "Gin",
                           name: "Atlas 2",
                           size: "M",
                           checkCycle: 6,
                           checkLog: [
                            Check(date: Date(timeIntervalSinceNow: -10000))
                           ]),
                Paraglider(brand: "U-Turn",
                           name: "Infinity 5",
                           size: "M",
                           checkCycle: 6,
                           checkLog: [
                            Check(date: Date(timeIntervalSinceNow: -160 * 60 * 60 * 24))
                           ]),
                Paraglider(brand: "Gin",
                           name: "Explorer 2",
                           size: "S",
                           checkCycle: 12,
                           checkLog: [
                            Check(date: Date(timeIntervalSinceNow: -182 * 60 * 60 * 24))
                           ]),
                Reserve(brand: "Gin",
                        name: "Yeti",
                        checkCycle: 3)
            ])
    }
}
