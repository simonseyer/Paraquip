//
//  WingLoadGuidanceView.swift
//  Paraquip
//
//  Created by Simon Seyer on 26.03.23.
//

import SwiftUI

struct WingLoadGuidanceView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Guidance")
                .font(.title2)
                .padding(.bottom, 4)
            Text("Lower wing load \(Image(systemName: "arrow.down"))")
                .font(.title3)
                .padding(.bottom, 2)
            Text("lower_wing_load_list")

            Text("Higher wing load \(Image(systemName: "arrow.up"))")
                .font(.title3)
                .padding([.bottom, .top], 2)
            Text("higher_wing_load_list")

            Text("Further reading")
                .font(.title2)
                .padding([.bottom, .top], 4)
            Text("further_reading_text")
        }
        .font(.body.leading(.loose))
        .textSelection(.enabled)
    }
}

#Preview {
    WingLoadGuidanceView()
}
