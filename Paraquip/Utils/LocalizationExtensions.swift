//
//  LocalizationExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.03.23.
//

import Foundation

public func LocalizedString(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}
