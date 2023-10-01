//
//  IconExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 05.09.23.
//

import Foundation
import UIKit

@MainActor
extension String {
    var deviceSpecificIcon: String {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return self
        } else {
            return self.removingFill
        }
    }

    var removingFill: String {
        return self.replacingOccurrences(of: ".fill", with: "")
    }
}
