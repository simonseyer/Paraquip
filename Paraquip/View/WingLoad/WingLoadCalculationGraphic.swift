//
//  WingLoadCalculationGraphic.swift
//  Paraquip
//
//  Created by Simon Seyer on 26.03.23.
//

import SwiftUI

struct WingLoadCalculationGraphic: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Full takeoff weight (kg)")
                .padding([.leading, .trailing], 4)
            Divider()
                .frame(height: 1)
                .overlay(.primary)
            Text("Projected area of the wing (m²)")
                .padding([.leading, .trailing], 4)
        }
        .fixedSize()
        .monospaced()
        .font(.footnote)
    }
}

struct WingLoadCalculationGraphic_Previews: PreviewProvider {
    static var previews: some View {
        WingLoadCalculationGraphic()
    }
}
