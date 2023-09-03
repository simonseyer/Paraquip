//
//  FakeNotificationState.swift
//  Paraquip
//
//  Created by Simon Seyer on 31.08.23.
//

import Foundation

extension NotificationState {
    static func fake() -> NotificationState {
        return NotificationState(
            isEnabled: true,
            wasRequestRejected: false,
            configuration: [
                NotificationConfig(unit: .months, multiplier: 1),
                NotificationConfig(unit: .days, multiplier: 10)
            ]
        )
    }
}
