//
//  WingLoad.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.03.23.
//

import Foundation

struct WingLoad {
    let takeoffWeight: Measurement<UnitMass>?
    let projectedWingArea: Measurement<UnitArea>?
    let wingWeightRange: ClosedRange<Measurement<UnitMass>>?

    var current: Double? {
        guard let projectedWingArea, let takeoffWeight else {
            return nil
        }
        let weightValue = takeoffWeight.converted(to: .kilograms).value
        let projectedAreaValue = projectedWingArea.converted(to: .squareMeters).value
        return weightValue / projectedAreaValue
    }

    var certifiedRange: ClosedRange<Double>? {
        guard let projectedArea = projectedWingArea,
                let weightRange = wingWeightRange else {
            return nil
        }
        let minWeightValue = weightRange.lowerBound.converted(to: .kilograms).value
        let maxWeightValue = weightRange.upperBound.converted(to: .kilograms).value
        let projectedAreaValue = projectedArea.converted(to: .squareMeters).value
        return (minWeightValue / projectedAreaValue)...(maxWeightValue / projectedAreaValue)
    }

    var extendedRange: ClosedRange<Double> {
        let defaultMinimum = 3.8
        let defaultMaximum = 4.9
        let buffer = 0.1

        guard let range = certifiedRange else {
            return (defaultMinimum)...(defaultMaximum)
        }

        var lower = range.lowerBound
        var upper = range.upperBound

        if let current {
            lower = min(lower, current)
            upper = max(upper, current)
        }

        lower = min(defaultMinimum, lower - buffer).rounded(digits: 1, rule: .down)
        upper = max(defaultMaximum, upper + buffer).rounded(digits: 1, rule: .up)

        return lower...upper
    }
}
