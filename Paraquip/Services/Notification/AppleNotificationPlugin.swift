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

class AppleNotificationPlugin: NSObject, NotificationPlugin, UNUserNotificationCenterDelegate  {

    weak var delegate: (any NotificationsPluginDelegate)? {
        didSet {
            observeAuthorizationStatus(delegate: delegate)
        }
    }

    private let center = UNUserNotificationCenter.current()
    private let badgeIdentifier = "badge"
    private let logger = Logger(category: "NotificationPlugin")
    private var notificationTask: Task<Void, Never>?

    override init() {
        super.init()
        precondition(center.delegate == nil)
        center.delegate = self
    }

    deinit {
        notificationTask?.cancel()
    }

    private func observeAuthorizationStatus(delegate: (any NotificationsPluginDelegate)?) {
        notificationTask?.cancel()
        guard let delegate else { return }

        notificationTask = Task {
            let didBecomeActive = NotificationCenter.default
                .notifications(named: await UIApplication.didBecomeActiveNotification)
            for await _ in didBecomeActive {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                let authorizationStatus = settings.authorizationStatus.toAuthorizationStatus()
                await delegate.authorizationStatusDidChange(authorizationStatus)
            }
        }
    }

    func requestAuthorization() async throws {
        try await center.requestAuthorization(options: [.alert, .badge, .providesAppNotificationSettings])
    }

    func reset() async {
        await setBadge(count: 0)
        center.removeAllPendingNotificationRequests()
    }

    func setBadge(count: Int) async {
        do {
            try await center.setBadgeCount(count)
        } catch {
            logger.error("Failed to set badge count: \(error)")
        }
    }

    func add(notification: Notification) async throws {
        let content = UNMutableNotificationContent()
        content.title = notification.title.localizedUserNotificationString
        content.body = notification.body.localizedUserNotificationString
        content.userInfo = [
            "equipment": notification.equipmentId.uuidString,
            "notificationConfig": notification.notificationConfigId.uuidString
        ]

        var date = notification.date
        if let simulatedDate = Date.simulatedDate {
            let timeInterval = Date().distance(to: simulatedDate)
            date.addTimeInterval(-timeInterval)
            logger.notice("Notification \(notification.id) rescheduled to: \(date)")
        }

        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: notification.id,
                                            content: content,
                                            trigger: trigger)
        try await center.add(request)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
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

        // Detached task required to work around crash when opening notification
        Task.detached { [delegate] in
            await delegate?.didReceiveNotification(response)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        Task { [delegate] in
            await delegate?.didReceiveOpenSettings()
        }
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
