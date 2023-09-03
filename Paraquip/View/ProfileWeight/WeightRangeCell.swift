//
//  WeightRangeCell.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.07.23.
//

import SwiftUI

struct WeightRangeCell: View {

    @ObservedObject var equipment: Equipment
    let takeoffWeight: Double

    private let gradient = Gradient(stops: [
        .init(color: Color(uiColor: .systemOrange), location: 0.0),
        .init(color: .accentColor, location: 0.15),
        .init(color: .accentColor, location: 0.88),
        .init(color: .orange, location: 1.0)])

    private let oneSidedGradient = Gradient(stops: [
        .init(color: .accentColor, location: 0.0),
        .init(color: .accentColor, location: 0.85),
        .init(color: .orange, location: 1.0)])

    var body: some View {
        if let maxWeight = equipment.maxWeightValue {
            VStack {
                Text("\(equipment.brandName) \(equipment.equipmentName)")
                    .fontWeight(.medium)
                Gauge(value: (takeoffWeight), in: (equipment.minWeightValue ?? 0)...(maxWeight)) {
                    Text("\(equipment.brandName) \(equipment.equipmentName)")
                } currentValueLabel: {
                    Text("\(Int(takeoffWeight)) kg")
                } minimumValueLabel: {
                    if let minWeight = equipment.minWeightValue {
                        Text("\(Int(minWeight)) kg")
                    }
                } maximumValueLabel: {
                    Text("\(Int(maxWeight)) kg")
                }
                .gaugeStyle(.accessoryLinear)
                .tint(equipment.minWeightValue != nil ? gradient : oneSidedGradient)
            }.padding(.bottom)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    WeightRangeCell(equipment: CoreData.fakeProfile.paraglider!,
                    takeoffWeight: 80)
        .environment(\.managedObjectContext, .preview)
}
