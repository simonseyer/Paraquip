//
//  ProfileTests.swift
//  ParaquipTests
//
//  Created by Simon Seyer on 12.05.21.
//

import XCTest
@testable import Paraquip

class ProfileTests: XCTestCase {

    var profile: Profile!
    var paraglider: Equipment!
    var reserve: Equipment!

    override func setUpWithError() throws {
        paraglider = Paraglider(brand: Brand(name: "Gin", id: "gin"),
                                name: "Atlas 2",
                                size: "M",
                                checkCycle: 2,
                                checkLog: [Check(date: Date.offsetBy(days: 0))])
        reserve = Reserve(brand: Brand(name: "Gin", id: "gin"),
                          name: "Yeti",
                          checkCycle: 1,
                          checkLog: [Check(date: Date.offsetBy(days: -40))])
        profile = Profile(name: "", equipment: [paraglider, reserve])
    }

    func testEquipmentSorted() {
        XCTAssertEqual(profile.equipment[0].id, reserve.id)
        XCTAssertEqual(profile.equipment[1].id, paraglider.id)
    }
}
