//
//  ParaquipUITests.swift
//  ParaquipUITests
//
//  Created by Simon Seyer on 09.04.21.
//

import XCTest
import UIKit

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
        if UIDevice.current.userInterfaceIdiom == .pad {
            let device = XCUIDevice.shared
            device.orientation = .landscapeRight
        }

        let app = XCUIApplication()
        app.launchEnvironment = [
            "stateSimulated": "true",
            "animationsDisabled": "true",
            "notificationsSimulated": "true",
            "simulatedNotificationDate": "1632985185"
        ]
        setupSnapshot(app)
        app.launch()

        if UIDevice.current.userInterfaceIdiom == .phone {
            app.navigationBars.buttons[localized("Notifications")].tap()
            snapshot("05NotificationsScreen")

            app.buttons[localized("Close")].tap()
            app.buttons[localized("Your Equipment")].tap()

            snapshot("01ProfileScreen")

            app.collectionViews.buttons["Explorer 2"].tap()
            snapshot("02EquipmentScreen")

            app.buttons[localized("Your Equipment")].tap()
            app.navigationBars.buttons[localized("Weight Check")].tap()
            snapshot("03ProfileWeightScreen")

            app.collectionViews.element(boundBy: 0).swipeUp()
            app.staticTexts[localized("Wing load")].tap()
            snapshot("04WingLoadScreen")
        } else {
            app.buttons["ToggleSidebar"].tap()
            app.buttons[localized("Your Equipment")].tap()
            app.collectionViews.buttons["Explorer 2"].tap()

            snapshot("01ProfileScreen")

            app.navigationBars.buttons[localized("Weight Check")].tap()
            snapshot("03ProfileWeightScreen")

            app.staticTexts[localized("Wing load")].tap()
            snapshot("04WingLoadScreen")

            app.navigationBars[localized("Wing load")].buttons[localized("Close")].tap()
            app.navigationBars[localized("Weight Check")].buttons[localized("Close")].tap()

            app.navigationBars.buttons[localized("Notifications")].tap()
            snapshot("05NotificationsScreen")
            app.navigationBars[localized("Notifications")].buttons[localized("Close")].tap()

            if app.buttons["ToggleSidebar"].exists {
                app.buttons["ToggleSidebar"].tap()
            } else {
                app.swipeLeft()
            }

            snapshot("02EquipmentScreen")
        }
    }

    func localized(_ key:String) -> String {
        var bundle = Bundle(for: type(of: self))
        if !deviceLanguage.isEmpty {
            let languageIdentifier = String(deviceLanguage.split(separator: "-")[0])
            bundle = Bundle(path: bundle.path(forResource: languageIdentifier, ofType: "lproj")!)!
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
