//
//  EquipmentTests.swift
//  ParaquipTests
//
//  Created by Simon Seyer on 15.05.21.
//

import XCTest
@testable import Paraquip

class EquipmentTests: XCTestCase {

    func testNextCheck() {
        let equipment = equipment(checkLog: [Check(date: date(offsetByDays: -40))])

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: date(offsetByDays: -40))!

        XCTAssert(Calendar.current.isDate(equipment.nextCheck, inSameDayAs: nextCheck))
    }

    func testNextCheckWithPurchaseDate() {
        let equipment = equipment(purchaseDate: date(offsetByDays: 0))

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: date(offsetByDays: 0))!

        XCTAssert(Calendar.current.isDate(equipment.nextCheck, inSameDayAs: nextCheck))
    }

    func testNextCheckWithPurchaseDateAndCheck() {
        let equipment = equipment(checkLog: [Check(date: date(offsetByDays: -40))],
                                  purchaseDate: date(offsetByDays: -60))

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: date(offsetByDays: -40))!

        XCTAssert(Calendar.current.isDate(equipment.nextCheck, inSameDayAs: nextCheck))
    }

    func date(offsetByDays days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }

    func equipment(checkLog: [Check] = [], purchaseDate: Date? = nil) -> Equipment {
        return Reserve(brand: Brand(name: "", id: ""), name: "", checkCycle: 1, checkLog: checkLog, purchaseDate: purchaseDate)
    }
}
