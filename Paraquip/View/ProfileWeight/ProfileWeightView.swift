//
//  ProfileWeightView.swift
//  Paraquip
//
//  Created by Simon Seyer on 05.12.21.
//

import SwiftUI

extension Measurement where UnitType == UnitMass {
    static var zero: Self {
        .init(value: 0, unit: .baseUnit())
    }
}

struct ProfileWeightView: View {

    @ObservedObject var profile: Profile
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    private var formatter: MeasurementFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumFractionDigits = 1

        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter = numberFormatter
        return formatter
    }

    @State private var editEquipment: Equipment?
    @State private var equipmentSumMeasurement: Measurement<UnitMass> = .zero
    @State private var sumMeasurement: Measurement<UnitMass> = .zero

    private func updateSum() {
        equipmentSumMeasurement = profile.allEquipment
            .compactMap { $0.weightMeasurement }
            .reduce(.zero, +)
        sumMeasurement = equipmentSumMeasurement + profile.pilotWeightMeasurement + profile.additionalWeightMeasurement
    }

    private func formatted(value: Measurement<UnitMass>) -> String {
        return formatter.string(from: value.converted(to: locale.weightUnit))
    }

    var body: some View {
        List {
            Section(header: Text("Equipment")) {
                ForEach(profile.allEquipment) { equipment in
                    Button {
                        editEquipment = equipment
                    } label: {
                        EquipmentWeightRow(equipment: equipment, formatter: formatted(value:))
                            .foregroundColor(.primary)
                    }
                }
                HStack {
                    ListIcon(image: Image(systemName: "sum"))
                        .padding(.trailing, 6)
                    Text("Sum")
                        .bold()
                    Spacer()
                    Text(formatted(value: equipmentSumMeasurement))
                        .monospacedDigit()
                        .bold()
                }
            }
            Section(header: Text("Pilot")) {
                HStack {
                    ListIcon(image: Image(systemName: "person.fill"))
                        .padding(.trailing, 6)
                    Slider(value: $profile.pilotWeight, in: 50...150, step: 1)
                    Text(formatted(value: profile.pilotWeightMeasurement))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .frame(minWidth: 80, alignment: .trailing)
                }
                HStack {
                    ListIcon(image: Image(systemName: "takeoutbag.and.cup.and.straw.fill"))
                        .padding(.trailing, 6)
                    Slider(value: $profile.additionalWeight, in: 0...20)
                    Text(formatted(value: profile.additionalWeightMeasurement))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .frame(minWidth: 80, alignment: .trailing)
                }
            }
            Section {
                HStack {
                    ListIcon(image: Image(systemName: "sum"))
                        .padding(.trailing, 6)
                    Text("Takeoff weight")
                        .bold()
                    Spacer()
                    Text(formatted(value: sumMeasurement))
                        .monospacedDigit()
                        .bold()
                }
                ForEach(profile.allEquipment) { equipment in
                    EquipmentWeightRangeRow(equipment: equipment, sumMeasurement: sumMeasurement)
                }
            }
        }
        .navigationBarTitle("Weight Check")
        .sheet(item: $editEquipment) { equipment in
            NavigationView {
                EditEquipmentView(equipment: equipment, locale: locale)
            }
        }
        .onAppear {
            updateSum()
        }
        .onChange(of: profile.pilotWeightMeasurement) { _ in
            updateSum()
        }
        .onChange(of: profile.additionalWeightMeasurement) { _ in
            updateSum()
        }
        .onChange(of: editEquipment) { _ in
            updateSum()
        }
        .onDisappear {
            try! managedObjectContext.save()
        }
    }
}

struct EquipmentWeightRow: View {

    @ObservedObject var equipment: Equipment
    let formatter: (Measurement<UnitMass>) -> String

    var body: some View {
        HStack {
            ListIcon(image: Image(equipment.typeIconName))
                .padding(.trailing, 6)
            Text(equipment.equipmentName)
            Spacer()
            if let weight = equipment.weightMeasurement {
                Text(formatter(weight))
                    .monospacedDigit()
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EquipmentWeightRangeRow: View {

    @ObservedObject var equipment: Equipment
    var sumMeasurement: Measurement<UnitMass>

    var body: some View {
            if let weightRange = equipment.weightRangeMeasurement {
                VStack {
                    Text("\(equipment.brandName) \(equipment.equipmentName)")
                    WeightRangeView(minWeight: weightRange.lowerBound,
                                    maxWeight: weightRange.upperBound,
                                    weight: sumMeasurement)
                }
            } else {
                EmptyView()
            }
    }
}

struct ProfileWeightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileWeightView(profile: CoreData.fakeProfile)
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
