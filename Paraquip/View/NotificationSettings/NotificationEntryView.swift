//
//  NotificationEntryView.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.05.21.
//

import SwiftUI

struct NotificationEntryView: View {

    @State private var config: NotificationConfig
    @State private var multiplierOptions: [Int] = []
    private let onChange: (NotificationConfig) -> Void

    init(config: NotificationConfig, onChange: @escaping ( NotificationConfig) -> Void) {
        _config = State(initialValue: config)
        self.onChange = onChange

        let multiplierOptions = Self.multiplierOptions(for: config.unit)
        _multiplierOptions = State(initialValue: multiplierOptions)
    }

    var body: some View {
        HStack(spacing: 0) {
            Label("", systemImage: "bell")
                .foregroundStyle(.primary)
            HStack(spacing: 14) {
                Group {
                    Picker("", selection: $config.multiplier) {
                        ForEach(multiplierOptions, id: \.self) { multiplier in
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
        .onChange(of: config) { _, value in
            onChange(value)
            updateState()
        }
    }

    private func updateState() {
        withAnimation {
            multiplierOptions = Self.multiplierOptions(for: config.unit)
        }
    }

    private static func multiplierOptions(for unit: NotificationConfig.Unit) -> [Int] {
        switch unit {
        case .days:
            return Array(0...31)
        case .months:
            return Array(0...6)
        }
    }
}

struct NotificationEntryView_Previews: PreviewProvider {
    static var previews: some View {
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
        #if os(visionOS)
        .glassBackgroundEffect()
        #endif
    }
}
