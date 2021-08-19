//
//  PillLabel.swift
//  Paraquip
//
//  Created by Simon Seyer on 19.08.21.
//

import SwiftUI

struct PillLabel: View {

    let content: LocalizedStringKey

    init(_ content: LocalizedStringKey) {
        self.content = content
    }

    var body: some View {
        Text(content)
            .font(.caption)
            .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(6)
    }
}

struct PillLabel_Previews: PreviewProvider {
    static var previews: some View {
        PillLabel("Test")
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
