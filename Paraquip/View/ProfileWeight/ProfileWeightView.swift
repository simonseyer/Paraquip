//
//  ProfileWeightView.swift
//  Paraquip
//
//  Created by Simon Seyer on 05.12.21.
//

import SwiftUI
import CoreData

struct ProfileWeightView: View {

    @ObservedObject var profile: Profile
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale
    
    @FetchRequest
    private var equipment: FetchedResults<Equipment>

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

    @State private var editEquipmentOperation: Operation<Equipment>?
    @State private var showingWingLoad = false
    
    init(profile: Profile) {
        self.profile = profile
        if ProcessInfo.isPreview {
            _equipment = FetchRequest(
                entity: Equipment.previewEntity,
                sortDescriptors: Equipment.defaultNSSortDescriptors,
                predicate: profile.equipmentPredicate
            )
        } else {
            _equipment = FetchRequest(
                sortDescriptors: Equipment.defaultSortDescriptors(),
                predicate: profile.equipmentPredicate
            )
        }
    }

    private func formatted(value: Measurement<UnitMass>) -> String {
        return formatter.string(from: value.converted(to: locale.weightUnit))
    }

    var body: some View {
        List {
            Section(header: Text("Equipment")) {
                ForEach(equipment) { equipment in
                    Button {
                        editEquipmentOperation = Operation(editing: equipment,
                                                           withParentContext: managedObjectContext)
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
                    Text(formatted(value: profile.equipmentWeightMeasurement))
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
                    Text(formatted(value: profile.takeoffWeightMeasurement))
                        .monospacedDigit()
                }
                .fontWeight(.medium)
                HStack {
                    ListIcon(image: Image(systemName: "scalemass.fill"))
                        .padding(.trailing, 8)
                    HStack(spacing: 4) {
                        Text("Wing load")
                        Button("\(Image(systemName: "info.circle"))") {
                            showingWingLoad.toggle()
                        }
                    }
                    Spacer()
                    if let wingLoad = profile.wingLoad {
                        Text(wingLoad, format: .number.precision(.fractionLength(2)))
                            .monospacedDigit()
                    } else {
                        Text("—")
                            .foregroundColor(.secondary)
                    }
                }
                .fontWeight(.medium)
                ForEach(equipment) { equipment in
                    if let weightRange = equipment.weightRangeMeasurement {
                        VStack {
                            Text("\(equipment.brandName) \(equipment.equipmentName)")
                                .fontWeight(.medium)
                            WeightRangeView(minWeight: weightRange.lowerBound,
                                            maxWeight: weightRange.upperBound,
                                            weight: profile.takeoffWeightMeasurement)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) {
                            $0[.leading]
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Weight Check")
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object, locale: locale)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .sheet(isPresented: $showingWingLoad) {
            WingLoadView(profile: profile)
                .presentationDetents([.medium, .large])
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

struct ProfileWeightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileWeightView(profile: CoreData.fakeProfile)
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
