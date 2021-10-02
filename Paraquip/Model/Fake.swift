//
//  Fake.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import Foundation

extension Profile {
    static func fake() -> Profile {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "de")

        return Profile(
            name: "Equipment",
            icon: .default,
            equipment: [
                Reserve(brand: Brand(name: "Nova", id: "nova"),
                        name: "Beamer 3 light",
                        checkCycle: 3,
                        checkLog: [],
                        purchaseDate: dateFormatter.date(from: "30.09.2020")!),
                Reserve(brand: Brand(name: "Ozone", id: "ozone"),
                        name: "Angel SQ",
                        checkCycle: 3,
                        checkLog: [
                            Check(date: dateFormatter.date(from: "14.07.2021")!)
                        ],
                        purchaseDate: dateFormatter.date(from: "30.09.2020")!),
                Harness(brand: Brand(name: "Woody Valley", id: "woody-valley"),
                        name: "Wani Light 2",
                        checkCycle: 12,
                        checkLog: [
                            Check(date: dateFormatter.date(from: "14.04.2021")!)
                        ],
                        purchaseDate: dateFormatter.date(from: "30.09.2020")!),
                Paraglider(brand: Brand(name: "Gin", id: "gin"),
                           name: "Explorer 2",
                           size: .small,
                           checkCycle: 12,
                           checkLog: [
                            Check(date: dateFormatter.date(from: "12.08.2021")!)
                           ],
                           purchaseDate: dateFormatter.date(from: "30.09.2020")!)
            ])
    }
}

extension NotificationState {
    static func fake() -> NotificationState {
        return NotificationState(
            isEnabled: true,
            wasRequestRejected: false,
            configuration: [
                NotificationConfig(unit: .months, multiplier: 1),
                NotificationConfig(unit: .days, multiplier: 10)
            ]
        )
    }
}
