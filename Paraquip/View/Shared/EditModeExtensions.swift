//
//  EditModeExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 02.10.23.
//

import Foundation
import SwiftUI

extension EditMode {
    var title: String {
        String(localized: self == .active ? "Done" : "Edit")
    }

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
