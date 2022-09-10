//
//  ParaquipUITests.swift
//  ParaquipUITests
//
//  Created by Simon Seyer on 09.04.21.
//

import XCTest

class SnapshotUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchEnvironment = [
            "isUITest": "true",
            "simulated_notification_date": "1632985185"
        ]
        setupSnapshot(app)
        app.launch()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        snapshot("04NotificationsScreen")

        app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 1).tap()
        app.collectionViews.buttons.element(boundBy: 0).tap()

        snapshot("01ProfileScreen")

        app.navigationBars.buttons.element(boundBy: 1).tap()
        snapshot("03ProfileWeightScreen")

        app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 0).tap()
        app.collectionViews.buttons["Explorer 2"].tap()

        snapshot("02EquipmentScreen")
    }
}
