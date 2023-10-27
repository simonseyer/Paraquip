//
//  NotificationEntryView.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.05.21.
//

import SwiftUI

struct NotificationEntryView: View {

    @State private var config: NotificationConfig
    private let onChange: (NotificationConfig) -> Void

    init(config: NotificationConfig, onChange: @escaping ( NotificationConfig) -> Void) {
        _config = State(initialValue: config)
        self.onChange = onChange
    }

    var body: some View {
        HStack(spacing: 0) {
            Label("", systemImage: "bell")
            HStack(spacing: 14) {
                Group {
                    Picker("", selection: $config.multiplier) {
                        ForEach(0...31, id: \.self) { multiplier in
                            Text("\(multiplier)")
                                .tag(multiplier)
                        }
                    }

                    Picker("", selection: $config.unit) {
                        Text("day(s)")
                            .tag(NotificationConfig.Unit.days)
                        Text("month(s)")
                            .tag(NotificationConfig.Unit.months)
                    }
                }
                .labelsHidden()
                #if os(iOS)
                .padding(.horizontal, 6)
                .background(.thinMaterial)
                .cornerRadius(6)
                #endif
                
                Text("before")
            }
        }
        .onChange(of: config) {
            onChange(config)
        }
    }
}

#Preview {
    Form {
        NotificationEntryView(
            config: .init(unit: .days, multiplier: 1),
            onChange: { _ in }
        )
        NotificationEntryView(
            config: .init(unit: .days, multiplier: 1),
            onChange: { _ in }
        )
    }
    .environment(\.locale, .init(identifier: "de"))
}
