//
//  NotificationSettingsView.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.05.21.
//

import SwiftUI

struct NotificationSettingsView: View {
    
    @State private var notificationsOn = false
    @State private var configurationSectionShown = false
    @State private var editMode: EditMode = .inactive

    @EnvironmentObject var store: NotificationsStore

    var footer: some View {
        return HStack {
            if store.state.wasRequestRejected {
                Label("notification_denied_info", systemImage: "exclamationmark.triangle.fill")
            } else {
                Text("notification_info")
            }
        }
    }

    var body: some View {
        Form {
            Section(header: Text(""), footer: footer.padding([.leading, .trailing])) {
                Toggle("Enable", isOn: $notificationsOn.animation())
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .disabled(store.state.wasRequestRejected)
            }
            
            if configurationSectionShown {
                Section {
                    ForEach(store.state.configuration) { config in
                        NotificationEntryView(
                            config: config
                        ) { newConfig in
                            store.update(notificationConfig: newConfig)
                        }
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    }
                    .onDelete(perform: { indexSet in
                        store.removeNotificationConfigs(atOffsets: indexSet)
                        if store.state.configuration.isEmpty {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    })
                    Button(action: {
                        withAnimation {
                            store.addNotificationConfig()
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
                store.enable {
                    withAnimation {
                        notificationsOn = store.state.isEnabled
                    }
                }
            } else {
                store.disable()
            }
        }
        .onChange(of: store.state.isEnabled) { value in
            withAnimation {
                notificationsOn = value
                configurationSectionShown = value
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if store.state.isEnabled && !store.state.configuration.isEmpty {
                    Button(editMode == .inactive ? "Edit" : "Done") {
                        withAnimation {
                            editMode.toggle()
                        }
                    }
                }
            }
        }
    }
}

struct NotificationSettingsViwe_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationSettingsView()
                .environmentObject(
                    NotificationsStore(state: .init(
                                        isEnabled: true,
                                        wasRequestRejected: false,
                                        configuration: [NotificationConfig(unit: .months, multiplier: 1)])
                    )
                )
        }

        NavigationView {
            NotificationSettingsView()
                .environmentObject(
                    NotificationsStore(state: .init(
                                        isEnabled: false,
                                        wasRequestRejected: true,
                                        configuration: [])
                    )
                )
        }
    }
}
