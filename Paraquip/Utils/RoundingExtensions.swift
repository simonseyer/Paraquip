//
//  RoundingExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.03.23.
//

import Foundation

extension Double {
    func rounded(digits: Int, rule: FloatingPointRoundingRule) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded(rule) / multiplier
    }
}
