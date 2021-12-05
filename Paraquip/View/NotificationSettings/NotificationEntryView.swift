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

    @State private var unitOptions: [String] = []
    @State private var multiplierOptions: [String] = []

    @State private var unitPickerVisible = false
    @State private var multiplierPickerVisible = false

    @State private var unitIndex: Int = 0
    @State private var multiplierIndex: Int = 0

    init(config: NotificationConfig, onChange: @escaping ( NotificationConfig) -> Void) {
        _config = State(initialValue: config)
        self.onChange = onChange

        let unitOptions = Self.unitOptions(for: config.multiplier)
        let multiplierOptions = Self.multiplierOptions(for: config.unit)

        let unitIndex = config.unit.rawValue
        let multiplierIndex = min(max(config.multiplier, 0), multiplierOptions.count - 1)

        _unitOptions = State(initialValue: unitOptions)
        _multiplierOptions = State(initialValue: multiplierOptions)

        _unitIndex = State(initialValue: unitIndex)
        _multiplierIndex = State(initialValue: multiplierIndex)
    }

    var body: some View {
        HStack {
            ListIcon(image: Image(systemName: "bell.fill"))
            ZStack {
                PickerOverlay(
                    options: $multiplierOptions,
                    selectionIndex: $multiplierIndex,
                    isVisible: $multiplierPickerVisible
                )
                .frame(width: 0)
                SelectableText(
                    text: multiplierOptions[multiplierIndex],
                    isSelected: $multiplierPickerVisible
                )
            }
            ZStack {
                PickerOverlay(
                    options: $unitOptions,
                    selectionIndex: $unitIndex,
                    isVisible: $unitPickerVisible
                )
                .frame(width: 0)
                SelectableText(
                    text: unitOptions[unitIndex],
                    isSelected: $unitPickerVisible
                )
            }
            Text("before check")
                .lineLimit(1)
        }
        .onTapGesture {
            unitPickerVisible = false
            multiplierPickerVisible = false
        }
        .onChange(of: multiplierIndex) { value in
            config.multiplier = value
            updateState()
        }
        .onChange(of: unitIndex) { value in
            config.unit = .init(rawValue: value)!
            updateState()
        }
        .onChange(of: config) { value in
            onChange(value)
        }
    }

    private func updateState() {
        unitOptions = Self.unitOptions(for: config.multiplier)
        multiplierOptions = Self.multiplierOptions(for: config.unit)
        unitIndex = config.unit.rawValue
        multiplierIndex = min(max(multiplierIndex, 0), multiplierOptions.count - 1)
    }

    private static func unitOptions(for multiplier: Int) -> [String] {
        let plural = multiplier != 1
        let units = plural ? ["days", "months"] : ["day", "month"]
        return units.map { NSLocalizedString($0, comment: "") }
    }

    private static func multiplierOptions(for unit: NotificationConfig.Unit) -> [String] {
        switch unit {
        case .days:
            return (0...31).map { "\($0)" }
        case .months:
            return (0...6).map { "\($0)" }
        }
    }
}

struct NotificationEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationEntryView(
            config: .init(unit: .days, multiplier: 1),
            onChange: { _ in }
        )
        .previewLayout(.fixed(width: 350, height: 60))
        .environment(\.locale, .init(identifier: "de"))
    }
}

struct ListIcon: View {

    let image: Image

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                .foregroundColor(Color.accentColor)
                .frame(width: 30, height: 30)
            image
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.white)
                .font(.system(size: 15))
                .frame(width: 16, height: 16)
        }
    }
}
