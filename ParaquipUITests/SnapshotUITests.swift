//
//  ParaquipUITests.swift
//  ParaquipUITests
//
//  Created by Simon Seyer on 09.04.21.
//

import XCTest
import UIKit

@MainActor
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
            // Checks tab
            app.buttons[localized("Checks")].tap()
            snapshot("01Checks")

            app.navigationBars.buttons[localized("Notifications")].tap()
            snapshot("07Notifications")

            app.buttons[localized("Close")].tap()
            app.collectionViews.buttons.element(matching: .init(format: "label CONTAINS %@", "Angel SQ")).tap()
            snapshot("02CheckLog")

            // Equipment tab
            app.buttons[localized("Equipment")].tap()
            app.buttons[localized("Your Equipment")].tap()
            snapshot("05Profile")

            app.collectionViews.buttons.element(matching: .init(format: "label CONTAINS %@", "Explorer 2")).tap()
            snapshot("06Equipment")

            // Performance tab
            app.buttons[localized("Performance")].tap()
            app.buttons[localized("Your Equipment")].tap()
            snapshot("03Performance")

            app.collectionViews.element(boundBy: 0).swipeUp()
            app.staticTexts.element(matching: .init(format: "label CONTAINS %@", localized("Wing load"))).tap()
            snapshot("04WingLoad")
            app.buttons[localized("Close")].tap()
        } else {
            // Checks tab
            app.buttons[localized("Checks")].tap()

            app.buttons.element(matching: .init(format: "label CONTAINS %@", "Angel SQ")).tap()
            snapshot("01Checks")
            app.swipeDown(velocity: .fast) // Close popover

            app.navigationBars.buttons[localized("Notifications")].tap()
            snapshot("07Notifications")
            app.buttons[localized("Close")].tap()

            // Equipment tab
            app.buttons[localized("Equipment")].tap()
            app.buttons["ToggleSidebar"].tap()
            app.buttons[localized("Your Equipment")].tap()
            app.collectionViews.buttons.element(matching: .init(format: "label CONTAINS %@", "Explorer 2")).tap()
            snapshot("05Profile")

            // Performance tab
            app.buttons[localized("Performance")].tap()
            app.buttons[localized("Your Equipment")].tap()
            snapshot("03Performance")

            app.collectionViews.element(boundBy: 0).swipeUp()
            app.staticTexts.element(matching: .init(format: "label CONTAINS %@", localized("Wing load"))).tap()
            snapshot("04WingLoad")
            app.buttons[localized("Close")].tap()
        }
    }

    func localized(_ key:String) -> String {
        var bundle = Bundle(for: type(of: self))
        if !Snapshot.deviceLanguage.isEmpty {
            let languageIdentifier = String(Snapshot.deviceLanguage.split(separator: "-")[0])
            bundle = Bundle(path: bundle.path(forResource: languageIdentifier, ofType: "lproj")!)!
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
