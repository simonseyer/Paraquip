//
//  FakeNotificationPlugin.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.05.21.
//

import Foundation
import Combine

@MainActor
class FakeNotificationPlugin: NotificationPlugin {

    weak var delegate: (any NotificationsPluginDelegate)?

    func requestAuthorization() async throws {}

    func reset() async {}

    func setBadge(count: Int) async {}

    func add(notification: Notification) async throws {}
}
