//
//  NotificationPlugin.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.05.21.
//

import Foundation

enum AuthorizationStatus: String, CustomStringConvertible {
    case notDetermined, denied, authorized

    var description: String {
        rawValue
    }
}

protocol NotificationsPluginDelegate: AnyObject, Sendable {
    func authorizationStatusDidChange(_ authorizationStatus: AuthorizationStatus) async
    func didReceiveNotification(_ notification: NotificationResponse) async
    func didReceiveOpenSettings() async
}

@MainActor
protocol NotificationPlugin: AnyObject {

    var delegate: (any NotificationsPluginDelegate)? { get set }

    func requestAuthorization() async throws
    func reset() async
    func setBadge(count: Int) async
    func add(notification: Notification) async throws
}

struct Notification {
    let equipmentId: UUID
    let notificationConfigId: UUID
    let title: LocalizedNotificationString
    let body: LocalizedNotificationString
    let date: Date
}

struct LocalizedNotificationString: ExpressibleByStringLiteral {
    let key: String
    let arguments: [String]?

    init(key: String, arguments: [String]? = nil) {
        self.key = key
        self.arguments = arguments
    }

    init(stringLiteral value: StringLiteralType) {
        self.key = value
        self.arguments = nil
    }
}

extension Notification: Identifiable {
    var id: String {
        "\(equipmentId)--\(notificationConfigId)"
    }
}

struct NotificationResponse {
    let equipmentId: UUID
    let notificationConfigId: UUID
}

extension Notification: CustomStringConvertible {


    var description: String {
        let localizedTitle = String(key: title.key, arguments: title.arguments ?? [])
        let localizedBody = String(key: body.key, arguments: body.arguments ?? [])

        return "Notification(\"\(localizedTitle)\", \"\(localizedBody)\", equipment: \(equipmentId), notificationConfig: \(notificationConfigId) \(date))"
    }
}

extension String {
    init(key: String, arguments: [String]) {
        self.init(format: LocalizedString(key), arguments: arguments)
    }
}
