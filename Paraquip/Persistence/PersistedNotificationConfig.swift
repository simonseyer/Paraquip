//
//  PersistedNotificationConfig.swift
//  Paraquip
//
//  Created by Simon Seyer on 24.05.21.
//

import Foundation

struct PersistedNotificationState: Codable {

    var isEnabled: Bool
    var configuration: [PersistedNotificationConfig]
}

struct PersistedNotificationConfig: Codable {

    enum Unit: Int, Codable {
        case days, months
    }

    var id: UUID
    var unit: Unit
    var multiplier: Int
}
