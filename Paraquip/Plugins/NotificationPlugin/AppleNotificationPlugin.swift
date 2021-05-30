//
//  AppleNotificationPlugin.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.05.21.
//

import Foundation
import UserNotifications
import UIKit
import OSLog
import Combine

class AppleNotificationPlugin: NotificationPlugin {

    var authorizationStatus: AnyPublisher<AuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }

    var notificationReceived: AnyPublisher<NotificationResponse, Never> {
        notificationReceivedSubject.eraseToAnyPublisher()
    }

    var openSettingsReceived: AnyPublisher<Void, Never> {
        openSettingsReceivedSubject.eraseToAnyPublisher()
    }

    private let authorizationStatusSubject = PassthroughSubject<AuthorizationStatus, Never>()
    private let notificationReceivedSubject = PassthroughSubject<NotificationResponse, Never>()
    private let openSettingsReceivedSubject = PassthroughSubject<Void, Never>()

    private let center = UNUserNotificationCenter.current()
    private let notificationDelegateHandler: NotificationDelegateHandler
    private let badgeIdentifier = "badge"
    private let logger = Logger(category: "NotificationPlugin")

    private static let simulatedDate: Date? = {
        if let notificationDateString = ProcessInfo.processInfo.environment["simulated_notification_date"],
           let notificationTimeInterval = TimeInterval(notificationDateString) {
            return Date(timeIntervalSince1970: notificationTimeInterval)
        } else {
            return nil
        }
    }()

    init() {
        self.notificationDelegateHandler = NotificationDelegateHandler(
            notificationReceivedSubject: notificationReceivedSubject,
            openSettingsReceivedSubject: openSettingsReceivedSubject
        )

        precondition(center.delegate == nil)
        center.delegate = self.notificationDelegateHandler

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) {[weak self] _ in
            self?.refreshNotificationAuthorization()
        }
    }

    private func refreshNotificationAuthorization() {
        center.getNotificationSettings {[weak self] settings in
            DispatchQueue.main.async {
                let authorizationStatus = settings.authorizationStatus.toAuthorizationStatus()
                self?.authorizationStatusSubject.send(authorizationStatus)
            }
        }
    }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .providesAppNotificationSettings],
                                    completionHandler: completion)
    }

    func reset() {
        setBadge(count: 0)
        center.removeAllPendingNotificationRequests()
    }

    func setBadge(count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }

    func add(notification: Notification, completion: @escaping (Error?) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = notification.title.localizedUserNotificationString
        content.body = notification.body.localizedUserNotificationString
        content.userInfo = [
            "equipment": notification.equipmentId.uuidString,
            "notificationConfig": notification.notificationConfigId.uuidString
        ]

        var date = notification.date
        if let simulatedDate = Self.simulatedDate {
            let timeInterval = Date().distance(to: simulatedDate)
            date.addTimeInterval(-timeInterval)
            logger.notice("Notification \(notification.id) rescheduled to: \(date)")
        }

        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: notification.id,
                                            content: content,
                                            trigger: trigger)
        center.add(request, withCompletionHandler: completion)
    }
}

fileprivate extension LocalizedNotificationString {
    var localizedUserNotificationString: String {
        NSString.localizedUserNotificationString(forKey: key, arguments: arguments)
    }
}

fileprivate extension UNAuthorizationStatus {
    func toAuthorizationStatus() -> AuthorizationStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized, .ephemeral, .provisional:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
}

private class NotificationDelegateHandler: NSObject, UNUserNotificationCenterDelegate {

    private let notificationReceivedSubject: PassthroughSubject<NotificationResponse, Never>
    private let openSettingsReceivedSubject: PassthroughSubject<Void, Never>
    private let logger = Logger(category: "NotificationPlugin")

    init(notificationReceivedSubject: PassthroughSubject<NotificationResponse, Never>,
         openSettingsReceivedSubject: PassthroughSubject<Void, Never>) {
        self.notificationReceivedSubject = notificationReceivedSubject
        self.openSettingsReceivedSubject = openSettingsReceivedSubject
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        openSettingsReceivedSubject.send()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        guard let equipmentIdString = userInfo["equipment"] as? String,
              let notificationConfigIdString = userInfo["notificationConfig"] as? String,
              let equipmentId = UUID(uuidString: equipmentIdString),
              let notificationConfigId = UUID(uuidString: notificationConfigIdString) else {
            logger.warning("Unrecognized notification received")
            return
        }

        let response = NotificationResponse(
            equipmentId: equipmentId,
            notificationConfigId: notificationConfigId)
        notificationReceivedSubject.send(response)
    }
}
