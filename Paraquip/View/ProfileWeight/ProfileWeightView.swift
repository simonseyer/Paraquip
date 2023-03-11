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
    @State private var wingLoad: Double = 0

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
                        .padding(.trailing, 8)
                    Text("Sum")
                    Spacer()
                    Text(formatted(value: equipmentSumMeasurement))
                        .monospacedDigit()
                }
                .fontWeight(.medium)
            }
            Section(header: Text("Pilot")) {
                HStack {
                    ListIcon(image: Image(systemName: "person.fill"))
                        .padding(.trailing, 8)
                    Slider(value: $profile.pilotWeight, in: 50...150, step: 1)
                        .alignmentGuide(.listRowSeparatorLeading) {
                            $0[.leading]
                        }
                    Text(formatted(value: profile.pilotWeightMeasurement))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .frame(minWidth: 80, alignment: .trailing)
                }
                HStack {
                    ListIcon(image: Image(systemName: "takeoutbag.and.cup.and.straw.fill"))
                        .padding(.trailing, 8)
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
                        .padding(.trailing, 8)
                    Text("Takeoff weight")
                    Spacer()
                    Text(formatted(value: sumMeasurement))
                        .monospacedDigit()
                }
                .fontWeight(.medium)
                ForEach(profile.allEquipment) { equipment in
                    EquipmentWeightRangeRow(equipment: equipment, sumMeasurement: sumMeasurement)
                        .alignmentGuide(.listRowSeparatorLeading) {
                            $0[.leading]
                        }
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
        .defaultBackground()
    }
}

struct EquipmentWeightRow: View {

    @ObservedObject var equipment: Equipment
    let formatter: (Measurement<UnitMass>) -> String

    var body: some View {
        HStack {
            ListIcon(image: equipment.equipmentType.iconImage)
                .padding(.trailing, 8)
            Text(equipment.equipmentName)
            Text(equipment.equipmentSize)
                .foregroundStyle(.secondary)
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
    @State private var showingWingLoadHelp = false
    var sumMeasurement: Measurement<UnitMass>

    var wingLoad: Double? {
        guard let projectedArea = equipment.projectedAreaMeasurement else {
            return nil
        }
        let weightValue = sumMeasurement.converted(to: .kilograms).value
        let projectedAreaValue = projectedArea.converted(to: .squareMeters).value
        return weightValue / projectedAreaValue
    }
    
    var body: some View {
            if let weightRange = equipment.weightRangeMeasurement {
                VStack {
                    Text("\(equipment.brandName) \(equipment.equipmentName)")
                        .fontWeight(.medium)
                    WeightRangeView(minWeight: weightRange.lowerBound,
                                    maxWeight: weightRange.upperBound,
                                    weight: sumMeasurement)
                    if equipment is Paraglider {
                        HStack(spacing: 4) {
                            if let wingLoad {
                                Text("Wing Load").fontWeight(.bold) +
                                Text(": ").fontWeight(.bold) +
                                Text(wingLoad, format: .number.precision(.fractionLength(2)))
                                    .monospacedDigit()
                            } else {
                                Text("Wing Load").fontWeight(.bold)
                            }
                            Button("\(Image(systemName: "info.circle.fill"))") {
                                showingWingLoadHelp.toggle()
                            }
                            .buttonStyle(.plain)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showingWingLoadHelp) {
                    VStack(spacing: 10) {
                        Text("Wing Load")
                            .font(.headline)
                        if equipment.projectedAreaMeasurement == nil {
                            Text("wing_load_explanation") +
                            Text("\n\n") +
                            Text("missing_projected_area_hint")
                        } else {
                            Text("wing_load_explanation")
                        }
                        Spacer()
                    }
                    .padding(40)
                    .presentationDetents([.medium])
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
