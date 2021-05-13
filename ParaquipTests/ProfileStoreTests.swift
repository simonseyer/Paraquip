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

    override func setUpWithError() throws {
        profileStore = ProfileStore(profile: .fake())
    }

    func testUpdateName() {
        profileStore.update(name: "testName")
        XCTAssertEqual(profileStore.profile.name, "testName")
    }

    func testAppendCheck() {
        let equipment = profileStore.profile.equipment.first!
        let date = Date()

        profileStore.logCheck(for: equipment, date: date)

        guard profileStore.profile.equipment.first!.checkLog.count == 2 else {
            XCTFail("Unexpected check log count")
            return
        }
        XCTAssertEqual(profileStore.profile.equipment.first!.checkLog[2].date, date)
    }
}
