//
//  ProfileWeightView.swift
//  Paraquip
//
//  Created by Simon Seyer on 05.12.21.
//

import SwiftUI
import CoreData

extension Locale {
    var weightUnit: UnitMass {
        measurementSystem == .metric ? .kilograms : .pounds
    }
}

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

    @State private var showingWingLoad = false
    
    init(profile: Profile) {
        self.profile = profile
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile.equipmentPredicate
        )
    }

    private func formatted(value: Measurement<UnitMass>) -> String {
        return formatter.string(from: value.converted(to: locale.weightUnit))
    }

    var body: some View {
        List {
            Section(header: Text("Equipment")) {
                ForEach(equipment) { equipment in
                    EquipmentWeightRow(equipment: equipment, formatter: formatter)
                }
                HStack {
                    Label("Sum", systemImage: "sum")
                    Spacer()
                    Text(formatted(value: profile.equipmentWeightMeasurement))
                        .monospacedDigit()
                        .fontWeight(.medium)
                }
            }
            Section(header: Text("Pilot")) {
                HStack(spacing: 0) {
                    Label("", systemImage: "person")
                    Slider(value: $profile.pilotWeight, in: 50...150, step: 1)
                    Text(formatted(value: profile.pilotWeightMeasurement))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 80, alignment: .trailing)
                }
                HStack(spacing: 0) {
                    Label("", systemImage: "takeoutbag.and.cup.and.straw")
                    Slider(value: $profile.additionalWeight, in: 0...20)
                    Text(formatted(value: profile.additionalWeightMeasurement))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 80, alignment: .trailing)
                }
            }
            Section {
                HStack {
                    Label("Takeoff weight", systemImage: "sum")
                    Spacer()
                    Text(formatted(value: profile.takeoffWeightMeasurement))
                        .monospacedDigit()
                        .fontWeight(.medium)
                }
                HStack {
                    Label("Wing load \(Image(systemName: "info.circle"))",
                          systemImage: "scalemass")
                    Spacer()
                    Button {
                        showingWingLoad.toggle()
                    } label: {
                        if let wingLoad = profile.wingLoadValue {
                            WingLoadText(wingLoad: wingLoad,
                                         desiredWingLoad: profile.desiredWingLoadValue)
                            .fontWeight(.medium)
                        } else {
                            Text("—")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                ForEach(equipment) { equipment in
                    if let maxWeight = equipment.maxWeightValue {
                        VStack {
                            Text("\(equipment.brandName) \(equipment.equipmentName)")
                                .fontWeight(.medium)
                            WeightRangeView(minWeight: equipment.minWeightValue ?? 0,
                                            maxWeight: maxWeight,
                                            weight: profile.takeoffWeightMeasurement.value)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) {
                            $0[.leading]
                        }
                    }
                }
            }
        }
        .navigationBarTitle(profile.profileName)
        .sheet(isPresented: $showingWingLoad) {
            NavigationStack {
                WingLoadView(profile: profile)
                    .presentationDetents([.medium, .large])
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Close") {
                                showingWingLoad = false
                            }
                        }
                    }
            }
        }
    }
}

struct EquipmentWeightRow: View {

    @ObservedObject var equipment: Equipment
    @Environment(\.locale) var locale: Locale
    let formatter: MeasurementFormatter

    var body: some View {
        HStack {
            Label {
                let name = Text(equipment.equipmentName)
                let size = Text(equipment.equipmentSize)
                    .fontWeight(.light)
                Text("\(name) \(size)")
            } icon: {
                equipment.equipmentType.iconImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(3)
            }
            Spacer()
            if let weight = equipment.weightMeasurement {
                Text(formatter.string(from: weight.converted(to: locale.weightUnit)))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileWeightView(profile: CoreData.fakeProfile)
    }
    .environment(\.locale, .init(identifier: "de"))
    .environment(\.managedObjectContext, .preview)
}
