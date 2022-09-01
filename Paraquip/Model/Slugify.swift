//
//  Slugify.swift
//  Paraquip
//
//  Created by Simon Seyer on 23.08.22.
//

import Foundation

extension String {
    func slugified() -> String {
        lowercased().replacingOccurrences(of: " ", with: "-")
    }
}
