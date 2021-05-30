//
//  NotificationPlugin.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.05.21.
//

import Foundation
import Combine

enum AuthorizationStatus: String, CustomStringConvertible {
    case notDetermined, denied, authorized

    var description: String {
        rawValue
    }
}

protocol NotificationPlugin {

    var authorizationStatus: AnyPublisher<AuthorizationStatus, Never> { get }
    var notificationReceived: AnyPublisher<NotificationResponse, Never> { get }
    var openSettingsReceived: AnyPublisher<Void, Never> { get }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    func reset()
    func setBadge(count: Int)
    func add(notification: Notification, completion: @escaping (Error?) -> Void)
}

struct Notification {
    var equipmentId: UUID
    var notificationConfigId: UUID
    var title: LocalizedNotificationString
    var body: LocalizedNotificationString
    var date: Date
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
    var equipmentId: UUID
    var notificationConfigId: UUID
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
        self.init(format: NSLocalizedString(key, comment: ""), arguments: arguments)
    }
}
