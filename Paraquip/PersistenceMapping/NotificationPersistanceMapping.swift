//
//  NotificationPersistanceMapping.swift
//  Paraquip
//
//  Created by Simon Seyer on 24.05.21.
//

import Foundation

extension NotificationState {
    func toPersistence() -> PersistedNotificationState {
        return PersistedNotificationState(
            isEnabled: isEnabled,
            configuration: configuration.map { $0.toPersistence() }
        )
    }
}

extension PersistedNotificationState {
    func toModel() -> NotificationState {
        return NotificationState(
            isEnabled: isEnabled,
            wasRequestRejected: false,
            configuration: configuration.map { $0.toModel() }
        )
    }
}

extension NotificationConfig {
    func toPersistence() -> PersistedNotificationConfig {
        return PersistedNotificationConfig(
            id: id,
            unit: unit.toPersistence(),
            multiplier: multiplier
        )
    }
}

extension PersistedNotificationConfig {
    func toModel() -> NotificationConfig {
        return NotificationConfig(
            unit: unit.toModel(),
            multiplier: multiplier
        )
    }
}

extension NotificationConfig.Unit {
    func toPersistence() -> PersistedNotificationConfig.Unit {
        switch self {
        case .days:
            return .days
        case .months:
            return .months
        }
    }
}

extension PersistedNotificationConfig.Unit {
    func toModel() -> NotificationConfig.Unit {
        switch self {
        case .days:
            return .days
        case .months:
            return .months
        }
    }
}
