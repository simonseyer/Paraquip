//
//  NSNumberExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.04.23.
//

import Foundation

extension NSNumber {
    convenience init?(value: Double?) {
        guard let value else {
            return nil
        }
        self.init(value: value)
    }
}
