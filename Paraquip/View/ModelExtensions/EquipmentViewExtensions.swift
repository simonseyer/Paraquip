//
//  EquipmentViewExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 23.08.21.
//

import Foundation
import SwiftUI

extension Equipment {

    var icon: UIImage? {
        guard case .known(_, let logo) = equipmentBrand else {
            return nil
        }
        return UIImage(named: logo)
    }

    var localizedType: String {
        switch self {
        case is Paraglider:
            return "Paraglider"
        case is Reserve:
            return "Reserve"
        case is Harness:
            return "Harness"
        default:
            preconditionFailure("Unknown equipment type")
        }
    }
}
