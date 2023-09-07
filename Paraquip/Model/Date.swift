//
//  Date.swift
//  Paraquip
//
//  Created by Simon Seyer on 25.07.21.
//

import Foundation

extension Date {
    static var paraquipNow: Date {
        simulatedDate ?? Date()
    }

    static let simulatedDate: Date? = {
        if let notificationDateString = ProcessInfo.processInfo.environment["simulatedNotificationDate"],
           let notificationTimeInterval = TimeInterval(notificationDateString) {
            return Date(timeIntervalSince1970: notificationTimeInterval)
        } else {
            return nil
        }
    }()
}
