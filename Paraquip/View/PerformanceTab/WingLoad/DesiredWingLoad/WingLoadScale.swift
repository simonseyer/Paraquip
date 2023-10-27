//
//  WingLoadScale.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.03.23.
//

import SwiftUI

struct WingLoadScale: View {

    let range: ClosedRange<Double>

    private var scaleValues: [Double] {
        let from = range.lowerBound.rounded(digits: 1, rule: .up)
        let to = range.upperBound.rounded(digits: 1, rule: .down)
        let stride = stride(from: from, to: to, by: 0.1)
        // `dropFirst` to avoid line on the very edge of the scale
        return [Double](stride.dropFirst())
    }

    var body: some View {
        GeometryReader { geometry in
            ForEach(scaleValues, id: \.hashValue) { step in
                if step.truncatingRemainder(dividingBy: 0.5) == 0 {
                    VStack(spacing: 2) {
                        Rectangle()
                            .frame(width: 1, height: 8)
                        Text(step, format: .number)
                            .font(.caption2)
                    }.position(
                        x: geometry.size.width * relativePosition(of: step),
                        y: 11.6)
                } else {
                    Rectangle()
                        .frame(width: 1, height: 4)
                        .position(
                            x: geometry.size.width * relativePosition(of: step),
                            y: 2)
                }
            }
        }
        .opacity(0.5)
    }

    private func relativePosition(of load: Double) -> Double {
        (load - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

#Preview {
    WingLoadScale(range: 3.8...4.6)
}
