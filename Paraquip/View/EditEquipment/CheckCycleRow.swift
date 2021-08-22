//
//  CheckCycleRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.08.21.
//

import SwiftUI

struct CheckCycleRow: View {

    @Binding var checkCycle: Double

    var body: some View {
        GeometryReader { metrics in
            HStack {
                Slider(value: $checkCycle, in: 0...36, step: 1) {
                    EmptyView()
                }
                .frame(width: metrics.size.width * 0.65)
                Spacer()
                Text(checkCycle > 0 ? "\(Int(checkCycle)) months" : "Off")
                    .font(.body.monospacedDigit())
                    .foregroundColor(checkCycle > 0 ? .primary : Color(UIColor.systemGray))
            }
        }
    }
}

struct CheckCycleRow_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            CheckCycleRow(checkCycle: .constant(0))
            CheckCycleRow(checkCycle: .constant(3))
            CheckCycleRow(checkCycle: .constant(50))
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
