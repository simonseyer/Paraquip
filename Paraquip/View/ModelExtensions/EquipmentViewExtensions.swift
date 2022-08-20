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
}

extension Equipment.EquipmentType {
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(localizedNameString)
    }

    var localizedNameString: String {
        switch self {
        case .paraglider: return "Paraglider"
        case .harness: return "Harness"
        case .reserve: return "Reserve"
        }
    }

    var iconName: String {
        switch self {
        case .paraglider: return "paraglider"
        case .harness: return "harness"
        case .reserve: return "reserve"
        }
    }
}
