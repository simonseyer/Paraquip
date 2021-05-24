//
//  NotificationsStore.swift
//  Paraquip
//
//  Created by Simon Seyer on 20.05.21.
//

import Foundation
import UserNotifications
import UIKit

struct NotificationState {
    var isEnabled: Bool
    var wasRequestRejected: Bool
    var showNotificationSettings: Bool = false
}

class NotificationsStore: ObservableObject {

    private let center = UNUserNotificationCenter.current()
    private var notificationDelegateHandler: NotificationDelegateHandler?

    @Published private(set) var state: NotificationState

    init(state: NotificationState? = nil) {
        self.state = state ?? NotificationState(
            isEnabled: false,
            wasRequestRejected: false
        )

        setupNotificationHandler()
        setupAuthorizationRefresh()
        refreshNotificationAuthorization()
    }

    private func setupNotificationHandler() {
        self.notificationDelegateHandler = NotificationDelegateHandler(openSettings: {
            self.state.showNotificationSettings = true
        })
        center.delegate = self.notificationDelegateHandler
    }

    private func setupAuthorizationRefresh() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) {[weak self] _ in
            self?.refreshNotificationAuthorization()
        }
    }

    func enable(completion: @escaping () -> Void)  {
        center.requestAuthorization(options: [.alert, .badge, .providesAppNotificationSettings]) {[weak self] success, error in
            if let error = error {
                print("Failed to enable notifications: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                if success {
                    self?.state.isEnabled = true
                } else {
                    self?.state.wasRequestRejected = true
                }

                completion()
            }
        }
    }

    private func refreshNotificationAuthorization() {
        center.getNotificationSettings {[weak self] settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    self?.state.isEnabled = false
                    self?.state.wasRequestRejected = true
                } else {
                    self?.state.wasRequestRejected = false
                }
            }
        }
    }

    func disable() {
        state.isEnabled = false
    }

    func resetShowNotificationSettings() {
        state.showNotificationSettings = false
    }
}

private class NotificationDelegateHandler: NSObject, UNUserNotificationCenterDelegate {

    private let openSettings: () -> Void

    init(openSettings: @escaping () -> Void) {
        self.openSettings = openSettings
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        openSettings()
    }
}
