//
//  TestUtils.swift
//  ParaquipTests
//
//  Created by Simon Seyer on 17.08.21.
//

import Foundation

extension Date {
    static func offsetBy(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
}
