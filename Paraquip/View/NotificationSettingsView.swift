//
//  NotificationSettingsView.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.05.21.
//

import SwiftUI

class NotificationSettingsViewModel: ObservableObject {
    
    @Published var configuration: [NotificationConfig] = [
        NotificationConfig(unit: .months, multiplier: 1),
        //        NotificationConfig(unit: .days, multiplier: 15)
    ]
}

struct NotificationSettingsView: View {
    
    @State var notificationsOn = false
    @State private var editMode: EditMode = .inactive
    
    @ObservedObject var viewModel = NotificationSettingsViewModel()
    
    var body: some View {
        Form {
            Section(header: Text(""), footer: Text("notification_info").padding([.leading, .trailing])) {
                Toggle("Activate", isOn: $notificationsOn)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            }
            
            if notificationsOn {
                Section {
                    ForEach(Array(viewModel.configuration.enumerated()), id: \.1.id) { index, _ in
                        NotificationEntryView(
                            config: $viewModel.configuration[index]
                        )
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    }
                    .onDelete(perform: { indexSet in
                        viewModel.configuration.remove(atOffsets: indexSet)
                        if viewModel.configuration.isEmpty {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    })
                    if editMode == .inactive {
                        Button(action: {
                            withAnimation {
                                viewModel.configuration.append(NotificationConfig(unit: .months, multiplier: 1))
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
                                    .foregroundColor(Color.primary)
                                
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .ignoresSafeArea(.keyboard)
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if notificationsOn && !viewModel.configuration.isEmpty {
                    Button(editMode == .inactive ? "Edit" : "Done") {
                        withAnimation {
                            editMode.toggle()
                        }
                    }
                    .animation(.none)
                }
            }
        }
    }
}

struct NotificationSettingsViwe_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationSettingsView()
        }
    }
}
