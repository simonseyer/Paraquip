//
//  ToolbarButton.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.10.23.
//

import SwiftUI

/// A button safe to use in toolbars without glitchy behaviour
/// Issues observed when using NavigationSplitView (FB13302790)
struct ToolbarButton<SimpleLabel: View, ComplexLabel: View>: View {

    let isHidden: Bool
    let action: () -> Void
    let simpleLabel: () -> SimpleLabel
    let complexLabel: () -> ComplexLabel

    init(isHidden: Bool = false,
         action: @escaping () -> Void,
         @ViewBuilder simpleLabel: @escaping () -> SimpleLabel,
         @ViewBuilder complexLabel: @escaping () -> ComplexLabel) {
        self.isHidden = isHidden
        self.action = action
        self.simpleLabel = simpleLabel
        self.complexLabel = complexLabel
    }

    var body: some View {
        #if os(iOS)
        Button(action: action, label: simpleLabel)
            .opacity(isHidden ? 0 : 1)
            .animation(.none, value: isHidden)
        #else
        if !isHidden {
            Button(action: action, label: complexLabel)
        }
        #endif
    }
}

#Preview {
    ToolbarButton(action: {}) {
        Text("Test")
    } complexLabel: {
        Label("Test", systemImage: "gear")
    }
}
