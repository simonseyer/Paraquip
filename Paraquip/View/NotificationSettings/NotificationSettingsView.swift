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
                        Label("notification_denied_info", systemImage: "exclamationmark.triangle.fill")
                    } else {
                        Text("notification_info")
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
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    }
                    .onDelete(perform: { indexSet in
                        notificationService.removeNotificationConfigs(atOffsets: indexSet)
                        if notificationService.state.configuration.isEmpty {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    })
                    Button(action: {
                        withAnimation {
                            notificationService.addNotificationConfig()
                        }
                    }) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                                    .foregroundColor(Color(UIColor.systemGray2))
                                    .frame(width: 30, height: 30)
                                Image(systemName: "plus")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 18).bold())
                            }

                            Text("Add notification")
                                .padding([.leading], 5)
                                .disabled(editMode == .active)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .ignoresSafeArea(.keyboard)
        .environment(\.editMode, $editMode)
        .onChange(of: notificationsOn) { value in
            if value {
                notificationService.enable {
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
        .onChange(of: notificationService.state.isEnabled) { value in
            withAnimation {
                notificationsOn = value
                configurationSectionShown = value
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if notificationService.state.isEnabled && !notificationService.state.configuration.isEmpty {
                    Button(editMode == .inactive ? "Edit" : "Done") {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    }
                }
            }
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            NotificationSettingsView()
                .environmentObject(
                    NotificationService(state: .init(
                                        isEnabled: true,
                                        wasRequestRejected: false,
                                        configuration: [NotificationConfig(unit: .months, multiplier: 1)]),
                                       managedObjectContext: CoreData.previewContext,
                                       notifications: FakeNotificationPlugin()
                    )
                )
        }

        NavigationView {
            NotificationSettingsView()
                .environmentObject(
                    NotificationService(state: .init(
                                        isEnabled: false,
                                        wasRequestRejected: true,
                                        configuration: []),
                                       managedObjectContext: CoreData.previewContext,
                                       notifications: FakeNotificationPlugin()
                    )
                )
        }
    }
}
