//
//  ViewUtils.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import SwiftUI

extension EditMode {

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
