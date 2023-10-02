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

    var localizedNameString: String {
        switch self {
        case .paraglider: String(localized: "Paraglider")
        case .harness: String(localized: "Harness")
        case .reserve: String(localized: "Reserves")
        case .gear: String(localized: "Gear")
        }
    }

    var iconImage: Image {
        switch self {
        case .paraglider: return Image("paraglider")
        case .harness: return Image("harness")
        case .reserve: return Image("reserve")
        case .gear: return Image("gear")
        }
    }
}
