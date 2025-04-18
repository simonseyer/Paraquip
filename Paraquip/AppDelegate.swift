//
//  AppDelegate.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.2025.
//

import FirebaseCore
import FirebaseCrashlytics
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private let crashReportingKey = "crash_reporting_enabled"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        configureCrashReporting()

        return true
    }

    private func configureCrashReporting() {
        UserDefaults.standard.register(defaults: [crashReportingKey: true])
        let crashReportingEnabled = UserDefaults.standard.bool(forKey: crashReportingKey)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(crashReportingEnabled)
    }
}
