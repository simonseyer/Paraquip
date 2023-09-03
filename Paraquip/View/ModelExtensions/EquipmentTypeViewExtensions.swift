//
//  EquipmentTypeViewExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 03.09.23.
//

import Foundation
import SwiftUI

extension Equipment.EquipmentType {
    var iconImage: Image {
        switch self {
        case .paraglider: return Image("paraglider")
        case .harness: return Image("harness")
        case .reserve: return Image("reserve")
        case .gear: return Image("gear")
        }
    }
}
