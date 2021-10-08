//
//  EquipmentViewExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 23.08.21.
//

import Foundation
import SwiftUI

extension EquipmentModel {

    var icon: Image? {
        guard case .known(_, let logo) = equipmentBrand else {
            return nil
        }
        return Image(logo)
    }

    var localizedType: String {
        switch self {
        case is ParagliderModel:
            return "Paraglider"
        case is ReserveModel:
            return "Reserve"
        case is HarnessModel:
            return "Harness"
        default:
            preconditionFailure("Unknown equipment type")
        }
    }
}
