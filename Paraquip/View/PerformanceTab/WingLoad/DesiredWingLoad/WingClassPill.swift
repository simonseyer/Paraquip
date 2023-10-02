//
//  WingClassPill.swift
//  Paraquip
//
//  Created by Simon Seyer on 23.03.23.
//

import SwiftUI

struct WingClassPill: View {

    let text: Text

    var body: some View {
        text
            .padding([.leading, .trailing], 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(UIColor.systemGray), lineWidth: 1)
            )
            .font(.caption2)
            .fontWeight(.medium)
    }
}

struct WingClassPill_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            WingClassPill(text: Text("A"))
                .padding()
        }.background(Color.accentColor)
    }
}
