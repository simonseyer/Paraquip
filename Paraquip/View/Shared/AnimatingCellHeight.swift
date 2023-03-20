//
//  AnimatingCellHeight.swift
//  Paraquip
//
//  Created by Simon Seyer on 19.03.23.
//

import SwiftUI

struct AnimatingCellHeight: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(height: height)
    }
}

extension View {
    func animatingCellHeight(_ height: CGFloat) -> some View {
        modifier(AnimatingCellHeight(height: height))
    }
}
