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
        guard Self.brandIdentifier.contains(brandName.slugified()) else {
            return nil
        }
        return UIImage(named: brandName.slugified())
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
        case .gear: return "Gear"
        }
    }
}
