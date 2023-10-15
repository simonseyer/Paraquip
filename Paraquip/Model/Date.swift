//
//  Date.swift
//  Paraquip
//
//  Created by Simon Seyer on 25.07.21.
//

import Foundation

extension Date {
    static var paraquipNow: Date {
        simulatedDate ?? Date()
    }

    static let simulatedDate: Date? = {
        if let simulatedDateString = ProcessInfo.processInfo.environment["simulatedDate"] {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime]
            return dateFormatter.date(from: simulatedDateString)!
        } else {
            return nil
        }
    }()
}
