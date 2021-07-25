//
//  ProfileStoreTests.swift
//  ParaquipTests
//
//  Created by Simon Seyer on 12.05.21.
//

import XCTest
@testable import Paraquip

class ProfileStoreTests: XCTestCase {

    var profileStore: ProfileStore!

    private let dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter
    }()

    private let paragliderID = UUID()
    private let reserveID = UUID()

    func date(offsetByDays days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }

    override func setUpWithError() throws {
        let profile = Profile(id: UUID(),
                              name: "",
                              equipment: [
                                Paraglider(id: paragliderID,
                                           brand: Brand(name: "Gin", id: "gin"),
                                           name: "Atlas 2",
                                           size: "M",
                                           checkCycle: 2,
                                           checkLog: [Check(date: date(offsetByDays: 0))]),
                                Reserve(id: reserveID,
                                           brand: Brand(name: "Gin", id: "gin"),
                                           name: "Yeti",
                                           checkCycle: 1,
                                           checkLog: [Check(date: date(offsetByDays: -40))])
                              ])
        profileStore = ProfileStore(profile: profile)
    }

    func testUpdateName() {
        profileStore.update(name: "testName")
        XCTAssertEqual(profileStore.profile.name, "testName")
    }

    func testEquipmentSortedOnInit() {
        XCTAssertLessThan(profileStore.profile.equipment.first!.nextCheck,
                          profileStore.profile.equipment.last!.nextCheck)
    }

    func testAddNewCheck() {
        let equipment = profileStore.equipment(with: paragliderID)!
        let date = date(offsetByDays: 1)

        profileStore.logCheck(for: equipment, date: date)

        let newEquipment = profileStore.equipment(with: paragliderID)!

        XCTAssertEqual(newEquipment.checkLog.count, 2)
        XCTAssert(Calendar.current.isDate(newEquipment.checkLog.first!.date, inSameDayAs: date))
    }

    func testEquipmentSortingWithNewCheck() {
        let equipment = profileStore.equipment(with: paragliderID)!
        profileStore.logCheck(for: equipment, date: date(offsetByDays: 1))

        // Check equipment sorted after insert
        XCTAssertLessThan(profileStore.profile.equipment.first!.nextCheck,
                          profileStore.profile.equipment.last!.nextCheck)
    }

    func testAddOldCheck() {
        let equipment = profileStore.equipment(with: paragliderID)!
        let date = date(offsetByDays: -1)

        profileStore.logCheck(for: equipment, date: date)

        let newEquipment = profileStore.equipment(with: paragliderID)!

        XCTAssertEqual(newEquipment.checkLog.count, 2)
        XCTAssert(Calendar.current.isDate(newEquipment.checkLog.last!.date, inSameDayAs: date))
    }

    func testEquipmentSortingWithOldCheck() {
        let equipment = profileStore.equipment(with: paragliderID)!
        profileStore.logCheck(for: equipment, date: date(offsetByDays: -1))

        // Check equipment sorted after insert
        XCTAssertLessThan(profileStore.profile.equipment.first!.nextCheck,
                          profileStore.profile.equipment.last!.nextCheck)
    }

    func testNextCheck() {
        let equipment = profileStore.equipment(with: reserveID)!
        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: date(offsetByDays: -40))!
        XCTAssert(Calendar.current.isDate(equipment.nextCheck, inSameDayAs: nextCheck))
    }

    func testNextCheckWithOldCheck() {
        let equipment = profileStore.equipment(with: paragliderID)!

        profileStore.logCheck(for: equipment, date: date(offsetByDays: -1))

        let newEquipment = profileStore.equipment(with: paragliderID)!
        let nextCheck = Calendar.current.date(byAdding: .month, value: 2, to: date(offsetByDays: 0))!

        XCTAssert(Calendar.current.isDate(newEquipment.nextCheck, inSameDayAs: nextCheck))
    }

    func testNextCheckWithNewCheck() {
        let equipment = profileStore.equipment(with: reserveID)!

        profileStore.logCheck(for: equipment, date: date(offsetByDays: 0))

        let newEquipment = profileStore.equipment(with: reserveID)!
        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: date(offsetByDays: 0))!
        
        XCTAssert(Calendar.current.isDate(newEquipment.nextCheck, inSameDayAs: nextCheck))
    }

    func testDeleteCheck() {
        let equipment = profileStore.equipment(with: paragliderID)!

        profileStore.removeChecks(for: equipment, atOffsets: [equipment.checkLog.startIndex])

        let newEquipment = profileStore.equipment(with: paragliderID)!
        XCTAssertEqual(newEquipment.checkLog.count, 0)
    }
}
