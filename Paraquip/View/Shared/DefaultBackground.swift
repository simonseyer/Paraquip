//
//  DefaultBackground.swift
//  Paraquip
//
//  Created by Simon Seyer on 11.03.23.
//

import SwiftUI

extension View {
    func defaultBackground() -> some View {
        let color = Color(red: 0.97, green: 0.97, blue: 0.97)
        return self
            .scrollContentBackground(.hidden)
            .background(color)
    }
}
