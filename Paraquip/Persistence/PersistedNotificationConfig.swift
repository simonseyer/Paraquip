//
//  PersistedNotificationConfig.swift
//  Paraquip
//
//  Created by Simon Seyer on 24.05.21.
//

import Foundation
import Versionable

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

extension PersistedNotificationState: Versionable {
    var version: Version {
        .v1
    }

    static var mock: PersistedNotificationState {
        PersistedNotificationState(isEnabled: false, configuration: [])
    }

    enum Version: Int, VersionType {
        case v1
    }

    static func migrate(to: Version) -> Migration {
        switch to {
        case .v1:
            return .none
        }
    }
}
