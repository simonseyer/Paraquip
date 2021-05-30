//
//  LoggerExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.05.21.
//

import Foundation
import OSLog

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier!, category: category)
    }
}
