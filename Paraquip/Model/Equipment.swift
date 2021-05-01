//
//  Equipment.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

protocol Equipment {
    var id: UUID { get set }
    var brand: String { get set }
    var name: String { get set }
    var checkCycle: Int { get set }
    var checkLog: [Check] { get set }
}

struct Check: Identifiable {
    var id = UUID()
    var date: Date
}

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

extension Equipment {
    var nextCheck: Date {
        guard let lastCheck = checkLog.last?.date else {
            return Date()
        }

        return Calendar.current.date(byAdding: .month,
                                     value: checkCycle,
                                     to: lastCheck)!
    }
}
