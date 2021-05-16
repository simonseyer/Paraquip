//
//  NotificationEntryView.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.05.21.
//

import SwiftUI

struct NotificationEntryView: View {

    enum Unit: Int {
        case days, months
    }

    @Binding var unit: Unit
    @Binding var multiplier: Int

    @State private var unitOptions: [String]
    @State private var multiplierOptions: [String]

    @State private var unitPickerVisible = false
    @State private var multiplierPickerVisible = false

    @State private var unitIndex: Int
    @State private var multiplierIndex: Int

    init(unit: Binding<Unit>, multiplier: Binding<Int>) {
        _unit = unit
        _multiplier = multiplier
        _unitIndex = State(initialValue: unit.wrappedValue.rawValue)
        _multiplierIndex = State(initialValue: Self.safeMultiplierIndex(from: multiplier.wrappedValue))
        _unitOptions = State(initialValue: Self.localizedUnits(plural: multiplier.wrappedValue != 1))
        _multiplierOptions = State(initialValue: Self.multiplier(for:unit.wrappedValue))
    }

    private static func localizedUnits(plural: Bool) -> [String] {
        let units = plural ? ["days", "months"] : ["day", "month"]
        return units.map { NSLocalizedString($0, comment: "") }
    }

    private static func multiplier(for unit: Unit) -> [String] {
        switch unit {
        case .days:
            return (0...31).map { "\($0)" }
        case .months:
            return (0...6).map { "\($0)" }
        }
    }

    private static func safeMultiplierIndex(from value: Int) -> Int {
        return min(max(0, value), 31)
    }

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                    .foregroundColor(Color.accentColor)
                    .frame(width: 30, height: 30)
                Image(systemName: "bell.fill")
                    .foregroundColor(Color.white)
                    .font(.system(size: 15))
            }
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
            multiplier = value
            unitOptions = Self.localizedUnits(plural: value != 1)
        }
        .onChange(of: multiplier) { value in
            multiplierIndex = Self.safeMultiplierIndex(from: value)
        }
        .onChange(of: unitIndex) { value in
            unit = Unit(rawValue: value)!
            multiplierOptions = Self.multiplier(for: unit)
            multiplierIndex = min(multiplierIndex, multiplierOptions.count - 1)
        }
        .onChange(of: unit) { value in
            unitIndex = value.rawValue
        }
    }
}

struct NotificationEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationEntryView(
            unit: .constant(.days),
            multiplier: .constant(1)
        )
        .previewLayout(.fixed(width: 350, height: 60))
        .environment(\.locale, .init(identifier: "de"))
    }
}
