//
//  PersistanceVersions.swift
//  Paraquip
//
//  Created by Simon Seyer on 10.05.21.
//

import Foundation
import Versionable

extension PersistedProfile: Versionable {

    var version: Version {
        .v1
    }

    static var mock: PersistedProfile {
        Profile.fake().toPersistence()
    }

    enum Version: Int, VersionType {
        case v1
    }

    static func migrate(to: Version) -> Migration {
        switch to {
        case .v1:
            return .none
        }
    }
}
