//
//  EquipmentViewExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 23.08.21.
//

import Foundation
import SwiftUI

extension Equipment.EquipmentType {

    var pluralLocalizedName: String {
        switch self {
        case .paraglider: String(localized: "Paraglider")
        case .harness: String(localized: "Harness")
        case .reserve: String(localized: "Reserves")
        case .gear: String(localized: "Gear")
        }
    }

    var localizedName: String {
        switch self {
        case .paraglider: String(localized: "Paraglider")
        case .harness: String(localized: "Harness")
        case .reserve: String(localized: "Reserve")
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
