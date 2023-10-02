//
//  NotificationSettingsView.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.05.21.
//

import SwiftUI
import CoreData

struct NotificationSettingsView: View {
    
    @State private var notificationsOn = false
    @State private var configurationSectionShown = false
    @State private var editMode: EditMode = .inactive

    @EnvironmentObject var notificationService: NotificationService

    var body: some View {
        Form {
            Section {
                Toggle("Enable", isOn: $notificationsOn.animation())
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .disabled(notificationService.state.wasRequestRejected)
            } header: {
                Text("")
            } footer: {
                HStack {
                    if notificationService.state.wasRequestRejected {
                        Label("notification_denied_info", 
                              systemImage: "exclamationmark.triangle")
                    }
                }
            }
            
            if configurationSectionShown {
                Section {
                    ForEach(notificationService.state.configuration) { config in
                        NotificationEntryView(
                            config: config
                        ) { newConfig in
                            notificationService.update(notificationConfig: newConfig)
                        }
                    }
                    .onDelete { indexSet in
                        notificationService.removeNotificationConfigs(atOffsets: indexSet)
                        if notificationService.state.configuration.isEmpty {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    }
                    Button {
                        withAnimation {
                            notificationService.addNotificationConfig()
                        }
                    } label: {
                        Label("Add notification",
                              systemImage: "plus.circle")
                    }
                    .foregroundStyle(.primary)
                } header: {
                    HStack {
                        Text("Check Reminder")
                        Button(editMode.title) {
                            withAnimation {
                                editMode.toggle()
                            }
                        }
                        .controlSize(.mini)
                        .disabled(notificationService.state.configuration.isEmpty)
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .environment(\.editMode, $editMode)
        .onChange(of: notificationsOn) {
            if notificationsOn {
                Task {
                    await notificationService.enable()
                    withAnimation {
                        notificationsOn = notificationService.state.isEnabled
                    }
                }
            } else {
                notificationService.disable()
            }
        }
        .onAppear {
            let isEnabled = notificationService.state.isEnabled
            notificationsOn = isEnabled
            configurationSectionShown = isEnabled
        }
        .onChange(of: notificationService.state.isEnabled) {
            withAnimation {
                notificationsOn = notificationService.state.isEnabled
                configurationSectionShown = notificationService.state.isEnabled
            }
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            NotificationSettingsView()
                .environmentObject(
                    NotificationService(state: .init(
                                        isEnabled: true,
                                        wasRequestRejected: false,
                                        configuration: [NotificationConfig(unit: .months, multiplier: 1)]),
                                       managedObjectContext: .preview,
                                       notifications: FakeNotificationPlugin()
                    )
                )
        }

        NavigationStack {
            NotificationSettingsView()
                .environmentObject(
                    NotificationService(state: .init(
                                        isEnabled: false,
                                        wasRequestRejected: true,
                                        configuration: []),
                                       managedObjectContext: .preview,
                                       notifications: FakeNotificationPlugin()
                    )
                )
        }
    }
}
