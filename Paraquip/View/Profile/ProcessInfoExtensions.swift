//
//  ProcessInfoExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 10.09.22.
//

import Foundation

extension ProcessInfo {
    static var isPreview: Bool {
        return processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
