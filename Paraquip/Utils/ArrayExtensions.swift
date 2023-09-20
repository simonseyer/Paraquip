//
//  ArrayExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 20.09.23.
//

import Foundation

extension Array {
    func chunked(by size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
