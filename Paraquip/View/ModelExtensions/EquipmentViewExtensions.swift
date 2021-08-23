//
//  EquipmentViewExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 23.08.21.
//

import Foundation
import SwiftUI

extension Equipment {
    var icon: Image? {
        guard case .known(_, let logo) = brand else {
            return nil
        }
        return Image(logo)
    }

    var localizedType: String {
        switch self {
        case is Paraglider:
            return "Paraglider"
        case is Reserve:
            return "Reserve"
        case is Harness:
            return "Harness"
        case is PlaceholderEquipment:
            return ""
        default:
            preconditionFailure("Unknown equipment type")
        }
    }
}
