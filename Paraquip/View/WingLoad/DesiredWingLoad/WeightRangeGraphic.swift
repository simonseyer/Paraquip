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
                    RangeVisual(config: .certifiedLower)
                        .frame(width: width(visibleWeightRange.lowerBound, min))
                }

                if let recommendedMin = equipment.minRecommendedWeightValue {
                    RangeVisual(config: .recommmended)
                        .frame(width: width(equipment.minWeightValue ?? visibleWeightRange.lowerBound, recommendedMin))
                }

                Spacer()

                if let recommendedMax = equipment.maxRecommendedWeightValue {
                    RangeVisual(config: .recommmended)
                        .frame(width: width(recommendedMax, equipment.maxWeightValue ?? visibleWeightRange.upperBound))
                }

                if let max = equipment.maxWeightValue {
                    RangeVisual(config: .certifiedHigher)
                        .frame(width: width(max, visibleWeightRange.upperBound))
                }
            }
        }
    }
}

private struct RangeVisual: View {

    enum Configuration {
        case certifiedLower, certifiedHigher, recommmended
    }

    let config: Configuration

    private var isLower: Bool {
        config == .certifiedLower
    }

    @ViewBuilder
    var body: some View {
        Rectangle()
            .overlay(alignment: isLower ? .trailing : .leading) {
                if config != .recommmended {
                    arrowOverlay
                }
            }
            .foregroundColor(Color(UIColor.systemOrange))
            .opacity(config == .recommmended ? 0.3 : 0.6)
    }

    @ViewBuilder
    private var arrowOverlay: some View {
        VStack {
            Spacer()
            Image(systemName: "arrow.\(isLower ? "right" : "left")")
                .foregroundColor(.black)
                .font(.system(size: 8, weight: .bold))
                .padding(.bottom, 10)
                .padding(isLower ? .trailing : .leading, 6)
        }
    }
}

struct WeightRangeGraphic_Previews: PreviewProvider {

    static var paraglider: Paraglider {
        CoreData.fakeProfile.paraglider!
    }

    static var previews: some View {
        WeightRangeGraphic(
            equipment: paraglider,
            visibleWeightRange: 65...100)
        .frame(height: 40)
    }
}
