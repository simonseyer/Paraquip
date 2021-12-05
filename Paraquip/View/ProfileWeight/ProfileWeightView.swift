//
//  ProfileWeightView.swift
//  Paraquip
//
//  Created by Simon Seyer on 05.12.21.
//

import SwiftUI

extension ClosedRange where Bound == Double {
    func scale(_ value: Double) -> Double {
        lowerBound + value * (upperBound - lowerBound)
    }
}

struct ProfileWeightView: View {

    @ObservedObject var profile: Profile

    let pilotWeightRange = 50.0...150.0
    let additionalWeightRange = 0.0...20.0

    var pilotWeightMeasurement: Measurement<UnitMass> {
        Measurement(value: pilotWeightRange.scale(pilotWeight), unit: .kilograms)
    }

    var additionalWeightMeasurement: Measurement<UnitMass> {
        Measurement(value: additionalWeightRange.scale(additionalWeight), unit: .kilograms)
    }

    var sumMeasurement: Measurement<UnitMass> {
        let zeroKilograms = Measurement<UnitMass>(value: 0, unit: .kilograms)

        return profile.allEquipment
            .compactMap { $0.weightMeasurement }
            .reduce(zeroKilograms, +) +
        pilotWeightMeasurement +
        additionalWeightMeasurement
    }

    @State var pilotWeight: Double = 0.5
    @State var additionalWeight: Double = 0.5

    var body: some View {
        List {
            Section("Equipment") {
                ForEach(profile.allEquipment) { equipment in
                    HStack {
                        ListIcon(image: Image(equipment.typeIconName))
                            .padding(.trailing, 6)
                        Text(equipment.equipmentName)
                        Spacer()
                        if let weight = equipment.weightMeasurement {
                            Text(weight, format: .measurement(width: .abbreviated))
                                .monospacedDigit()
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Section("Pilot") {
                HStack {
                    ListIcon(image: Image(systemName: "person.fill"))
                        .padding(.trailing, 6)
                    Slider(value: $pilotWeight, in: 0...1)
                    Text(pilotWeightMeasurement, format: .measurement(width: .abbreviated))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
                HStack {
                    ListIcon(image: Image(systemName: "takeoutbag.and.cup.and.straw.fill"))
                        .padding(.trailing, 6)
                    Slider(value: $additionalWeight, in: 0...1)
                    Text(additionalWeightMeasurement, format: .measurement(width: .abbreviated))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
            }
            Section("Result") {
                HStack {
                    ListIcon(image: Image(systemName: "sum"))
                        .padding(.trailing, 6)
                    Text("Sum")
                    Spacer()
                    Text(sumMeasurement, format: .measurement(width: .abbreviated))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
                ForEach(profile.allEquipment) { equipment in
                    if let weightRange = equipment.weightRangeMeasurement {
                        VStack {
                            Text(equipment.equipmentName)
                                .foregroundColor(.secondary)
                            WeightRangeView(minWeight: weightRange.lowerBound,
                                            maxWeight: weightRange.upperBound,
                                            weight: sumMeasurement)
                        }
                    }
                }
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
