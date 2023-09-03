//
//  AppGroup.swift
//  Paraquip
//
//  Created by Simon Seyer on 31.08.23.
//

import Foundation

public enum AppGroup: String {
    case paraquip = "group.de.simonseyer.paraquip"

    public var containerURL: URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: rawValue)!
    }
}
