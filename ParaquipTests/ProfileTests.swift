//
//  ProfileTests.swift
//  ParaquipTests
//
//  Created by Simon Seyer on 12.05.21.
//

import XCTest
@testable import Paraquip

class ProfileTests: XCTestCase {

    private func equipment(checkCycle: Int = 1, checkLog: [Check] = [], purchaseDate: Date? = nil) -> Equipment {
        Harness(brand: Brand(name: "Gin", id: "gin"),
                name: "Yeti",
                checkCycle: checkCycle,
                checkLog: checkLog,
                purchaseDate: purchaseDate)
    }

    func testEquipmentSorted() {
        let equipment1 = equipment(checkLog: [Check(date: Date.offsetBy(days: -40))])
        let equipment2 = equipment(checkLog: [Check(date: Date.offsetBy(days: 0))])
        let profile = Profile(name: "", equipment: [equipment2, equipment1])

        XCTAssertEqual(profile.equipment[0].id, equipment1.id)
        XCTAssertEqual(profile.equipment[1].id, equipment2.id)
    }

    func testEquipmentSortedWithCheckOff() {
        let equipment1 = equipment(checkCycle: 0, checkLog: [Check(date: Date.offsetBy(days: -40))])
        let equipment2 = equipment(checkLog: [Check(date: Date.offsetBy(days: 0))])
        let profile = Profile(name: "", equipment: [equipment2, equipment1])

        XCTAssertEqual(profile.equipment[0].id, equipment2.id)
        XCTAssertEqual(profile.equipment[1].id, equipment1.id)
    }
}
