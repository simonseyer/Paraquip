//
//  FakeNotificationPlugin.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.05.21.
//

import Foundation
import Combine

class FakeNotificationPlugin: NotificationPlugin {

    var authorizationStatus = PassthroughSubject<AuthorizationStatus, Never>().eraseToAnyPublisher()
    var notificationReceived = PassthroughSubject<NotificationResponse, Never>().eraseToAnyPublisher()
    var openSettingsReceived = PassthroughSubject<Void, Never>().eraseToAnyPublisher()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        completion(true, nil)
    }

    func reset() {}

    func setBadge(count: Int) {}

    func add(notification: Notification, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}
