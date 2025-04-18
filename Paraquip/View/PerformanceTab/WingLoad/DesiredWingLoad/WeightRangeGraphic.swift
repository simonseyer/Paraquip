//
//  WeightRangeGraphic.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.04.23.
//

import SwiftUI

struct WeightRangeGraphic: View {

    @ObservedObject var equipment: Equipment
    let visibleWeightRange: ClosedRange<Double>

    private let certifiedOpacity = 0.8
    private let recommendedOpacity = 0.3

    var body: some View {
        GeometryReader { geometry in
            let position = { (weight: Double) -> Double in
                let lower = visibleWeightRange.lowerBound
                let upper = visibleWeightRange.upperBound
                return (weight - lower) / (upper - lower) * geometry.size.width
            }

            let width = {(min: Double, max: Double) in
                position(max) - position(min)
            }

            HStack(spacing: 0) {
                if let min = equipment.minWeightValue {
                    Rectangle()
                        .stripes()
                        .opacity(certifiedOpacity)
                        .frame(width: width(visibleWeightRange.lowerBound, min))
                }

                if let recommendedMin = equipment.minRecommendedWeightValue {
                    Rectangle()
                        .stripes()
                        .opacity(recommendedOpacity)
                        .frame(width: width(equipment.minWeightValue ?? visibleWeightRange.lowerBound, recommendedMin))
                }

                Spacer()

                if let recommendedMax = equipment.maxRecommendedWeightValue {
                    Rectangle()
                        .stripes()
                        .opacity(recommendedOpacity)
                        .frame(width: width(recommendedMax, equipment.maxWeightValue ?? visibleWeightRange.upperBound))
                }

                if let max = equipment.maxWeightValue {
                    Rectangle()
                        .stripes()
                        .opacity(certifiedOpacity)
                        .frame(width: width(max, visibleWeightRange.upperBound))
                }
            }
        }
    }
}

#Preview {
    WeightRangeGraphic(
        equipment: CoreData.fakeProfile.paraglider!,
        visibleWeightRange: 65...100)
    .frame(height: 40)
}
