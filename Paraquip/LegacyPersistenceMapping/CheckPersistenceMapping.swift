//
//  CheckPersistenceMapping.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

extension Check {
    func toPersistence() -> PersistedCheck {
        return PersistedCheck(id: id, date: date)
    }
}

extension PersistedCheck {
    func toModel() -> Check {
        return Check(id: id, date: date)
    }
}
