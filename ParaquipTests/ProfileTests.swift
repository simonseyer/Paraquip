//
//  ProfileTests.swift
//  ParaquipTests
//
//  Created by Simon Seyer on 12.05.21.
//

import XCTest
@testable import Paraquip

class ProfileTests: XCTestCase {

    private func equipment(no: Int, checkCycle: Int = 1, checkLog: [Check] = [], purchaseDate: Date? = nil) -> Equipment {
        Harness(id: UUID(uuidString: "21EFDEB2-17D1-441C-977C-0EAF9E789D8\(no)")!,
                brand: Brand(name: "Gin", id: "gin"),
                name: "Yeti",
                checkCycle: checkCycle,
                checkLog: checkLog,
                purchaseDate: purchaseDate)
    }

    func testEquipmentSorted() {
        let equipment1 = equipment(no: 1, checkLog: [Check(date: Date.offsetBy(days: -40))])
        let equipment2 = equipment(no: 2, checkLog: [Check(date: Date.offsetBy(days: 0))])
        let profile = Profile(name: "", icon: .default, equipment: [equipment2, equipment1])

        XCTAssertEqual(profile.equipment[0].id, equipment1.id)
        XCTAssertEqual(profile.equipment[1].id, equipment2.id)
    }

    func testEquipmentSortedWithCheckOff() {
        let equipment1 = equipment(no: 1, checkLog: [Check(date: Date.offsetBy(days: 0))])
        let equipment2 = equipment(no: 2, checkCycle: 0, checkLog: [Check(date: Date.offsetBy(days: -40))])
        let profile = Profile(name: "", icon: .default, equipment: [equipment2, equipment1])

        XCTAssertEqual(profile.equipment[0].id, equipment1.id)
        XCTAssertEqual(profile.equipment[1].id, equipment2.id)
    }

    func testEquipmentSortedWithAllChecksOff() {
        let equipment1 = equipment(no: 1, checkCycle: 0, checkLog: [Check(date: Date.offsetBy(days: -40))])
        let equipment2 = equipment(no: 2, checkCycle: 0, checkLog: [Check(date: Date.offsetBy(days: 0))])
        let profile = Profile(name: "", icon: .default, equipment: [equipment2, equipment1])

        XCTAssertEqual(profile.equipment[0].id, equipment1.id)
        XCTAssertEqual(profile.equipment[1].id, equipment2.id)
    }

    func testEquipmentSortedWithAllChecksOffWithoutOneCheck() {
        let equipment1 = equipment(no: 1, checkCycle: 0, checkLog: [])
        let equipment2 = equipment(no: 2, checkCycle: 0, checkLog: [Check(date: Date.offsetBy(days: 0))])
        let profile = Profile(name: "", icon: .default, equipment: [equipment2, equipment1])

        XCTAssertEqual(profile.equipment[0].id, equipment1.id)
        XCTAssertEqual(profile.equipment[1].id, equipment2.id)
    }

    func testEquipmentSortedWithAllChecksOffWithoutAllChecks() {
        let equipment1 = equipment(no: 1, checkCycle: 0, checkLog: [])
        let equipment2 = equipment(no: 2, checkCycle: 0, checkLog: [])
        let profile = Profile(name: "", icon: .default, equipment: [equipment2, equipment1])

        XCTAssertEqual(profile.equipment[0].id, equipment1.id)
        XCTAssertEqual(profile.equipment[1].id, equipment2.id)
    }
}
