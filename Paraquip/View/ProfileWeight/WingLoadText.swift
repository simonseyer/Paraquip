//
//  WingLoadText.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.03.23.
//

import SwiftUI

struct WingLoadText: View {

    let wingLoad: Double
    let desiredWingLoad: Double

    private var deviation: Double {
        abs(wingLoad - desiredWingLoad)
    }

    private let gradient = Gradient(stops: [
        .init(color: Color(uiColor: .systemOrange), location: 0.0),
        .init(color: .accentColor, location: 0.1),
        .init(color: .accentColor, location: 0.90),
        .init(color: .orange, location: 1.0)])

    private var deviationColor: Color {
        if deviation > 0.2 {
           return Color(UIColor.systemRed)
        } else {
           return Color(UIColor.systemOrange)
        }
    }

    var body: some View {
        Gauge(
            value: wingLoad,
            in: (desiredWingLoad - 0.2)...(desiredWingLoad + 0.2),
            label: { Text("") },
            currentValueLabel: { Text("\(wingLoad, format: .number.precision(.fractionLength(2)))").monospacedDigit() }
        ).tint(gradient)
            .gaugeStyle(.accessoryCircular)
//        HStack(spacing: 4) {
//            Text(wingLoad, format: .number.precision(.fractionLength(2)))
//                .monospacedDigit()
//            Group {
//                if deviation <= 0.1 {
//                    Image(systemName: "equal.circle")
//                } else if wingLoad > desiredWingLoad {
//                    Image(systemName: "arrow.up.circle")
//                        .foregroundColor(deviationColor)
//                } else if wingLoad < desiredWingLoad {
//                    Image(systemName: "arrow.down.circle")
//                        .foregroundColor(deviationColor)
//                }
//            }
//            .fontWeight(.regular)
//        }
    }
}

struct WingLoadText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            WingLoadText(wingLoad: 4.5, desiredWingLoad: 4.3)
            WingLoadText(wingLoad: 4.47, desiredWingLoad: 4.3)
            WingLoadText(wingLoad: 4.33, desiredWingLoad: 4.3)
            WingLoadText(wingLoad: 4.18, desiredWingLoad: 4.3)
            WingLoadText(wingLoad: 4.0, desiredWingLoad: 4.3)
        }
    }
}
