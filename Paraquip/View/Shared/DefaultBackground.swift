//
//  DefaultBackground.swift
//  Paraquip
//
//  Created by Simon Seyer on 11.03.23.
//

import SwiftUI

extension View {
    func defaultBackground() -> some View {
        let color = Color("Background")
        return self
            .scrollContentBackground(.hidden)
            .background(color)
    }
}
