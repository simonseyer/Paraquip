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

    private var deviationColor: Color {
        if deviation > 0.2 {
           return Color(UIColor.systemRed)
        } else {
           return Color(UIColor.systemOrange)
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(wingLoad, format: .number.precision(.fractionLength(2)))
                .monospacedDigit()
            Group {
                if deviation <= 0.1 {
                    Image(systemName: "equal.circle")
                } else if wingLoad > desiredWingLoad {
                    Image(systemName: "arrow.up.circle")
                        .foregroundStyle(deviationColor)
                } else if wingLoad < desiredWingLoad {
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(deviationColor)
                }
            }
            .fontWeight(.regular)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        WingLoadText(wingLoad: 4.5, desiredWingLoad: 4.3)
        WingLoadText(wingLoad: 4.47, desiredWingLoad: 4.3)
        WingLoadText(wingLoad: 4.33, desiredWingLoad: 4.3)
        WingLoadText(wingLoad: 4.18, desiredWingLoad: 4.3)
        WingLoadText(wingLoad: 4.0, desiredWingLoad: 4.3)
    }
}
