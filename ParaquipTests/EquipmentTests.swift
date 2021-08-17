//
//  EquipmentTests.swift
//  ParaquipTests
//
//  Created by Simon Seyer on 15.05.21.
//

import XCTest
@testable import Paraquip

class EquipmentTests: XCTestCase {

    func equipment(checkCycle: Int = 1, checkLog: [Check] = [], purchaseDate: Date? = nil) throws -> Equipment {
        throw XCTSkip()
    }

    func testCheckLogSorted() throws {
        let equipment = try equipment(checkLog: [
            Check(date: Date.offsetBy(days: -40)),
            Check(date: Date.offsetBy(days: 1))
        ])

        XCTAssert(Calendar.current.isDate(equipment.checkLog[0].date, inSameDayAs: Date.offsetBy(days: 1)))
        XCTAssert(Calendar.current.isDate(equipment.checkLog[1].date, inSameDayAs: Date.offsetBy(days: -40)))
    }

    func testNextCheck() throws {
        let equipment = try equipment(checkLog: [Check(date: Date.offsetBy(days: -40))])

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date.offsetBy(days: -40))!
        XCTAssert(Calendar.current.isDate(equipment.nextCheck, inSameDayAs: nextCheck))
    }

    func testNextCheckWithMultipleChecks() throws {
        let equipment = try equipment(checkLog: [
            Check(date: Date.offsetBy(days: -40)),
            Check(date: Date.offsetBy(days: 1))
        ])

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date.offsetBy(days: 1))!
        XCTAssert(Calendar.current.isDate(equipment.nextCheck, inSameDayAs: nextCheck))
    }

    func testNextCheckWithPurchaseDate() throws {
        let equipment = try equipment(purchaseDate: Date.offsetBy(days: 0))

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date.offsetBy(days: 0))!
        XCTAssert(Calendar.current.isDate(equipment.nextCheck, inSameDayAs: nextCheck))
    }

    func testNextCheckWithPurchaseDateAndCheck() throws {
        let equipment = try equipment(checkLog: [Check(date: Date.offsetBy(days: -40))],
                                      purchaseDate: Date.offsetBy(days: -60))

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date.offsetBy(days: -40))!
        XCTAssert(Calendar.current.isDate(equipment.nextCheck, inSameDayAs: nextCheck))
    }
}

class ParagliderTests: EquipmentTests {
    override func equipment(checkCycle: Int, checkLog: [Check], purchaseDate: Date?) throws -> Equipment {
        Paraglider(brand: Brand(name: "Gin", id: "gin"),
                   name: "Atlas 2",
                   size: "M",
                   checkCycle: checkCycle,
                   checkLog: checkLog,
                   purchaseDate: purchaseDate)
    }
}

class ReserveTests: EquipmentTests {
    override func equipment(checkCycle: Int, checkLog: [Check], purchaseDate: Date?) throws -> Equipment {
        Reserve(brand: Brand(name: "Gin", id: "gin"),
                name: "Yeti",
                checkCycle: checkCycle,
                checkLog: checkLog,
                purchaseDate: purchaseDate)
    }
}

class HarnessTests: EquipmentTests {
    override func equipment(checkCycle: Int, checkLog: [Check], purchaseDate: Date?) throws -> Equipment {
        Harness(brand: Brand(name: "Gin", id: "gin"),
                name: "Yeti",
                checkCycle: checkCycle,
                checkLog: checkLog,
                purchaseDate: purchaseDate)
    }
}
