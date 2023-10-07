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
        HStack {
            Slider(value: $checkCycle, in: 0...36, step: 1) {
                EmptyView()
            }
            HStack {
                Spacer()
                Text(checkCycle > 0 ? "\(Int(checkCycle)) months" : "Off")
                    .font(.body.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(width: 100)
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
