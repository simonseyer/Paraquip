//
//  ErrorExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 30.05.21.
//

import Foundation

extension Error {
    var description: String {
        return (self as NSError).userInfo[NSDebugDescriptionErrorKey] as? String ?? localizedDescription
    }
}
