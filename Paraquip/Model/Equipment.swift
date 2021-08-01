//
//  Equipment.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

protocol Equipment {
    var id: UUID { get set }
    var brand: Brand { get set }
    var name: String { get set }
    var checkCycle: Int { get set }
    var checkLog: [Check] { get set }
    var purchaseDate: Date? { get set }
}

struct Check: Identifiable {
    var id = UUID()
    var date: Date
}

enum CheckUrgency {
    case now, soon, later
}

extension Equipment {
    var nextCheck: Date {
        guard let lastCheck = checkLog.first?.date ?? purchaseDate else {
            return Date.now
        }

        return Calendar.current.date(byAdding: .month,
                                     value: checkCycle,
                                     to: lastCheck)!
    }

    var checkUrgency: CheckUrgency {
        let months = Calendar.current.dateComponents([.month], from: Date.now, to: nextCheck).month ?? 0

        if Calendar.current.isDate(nextCheck, inSameDayAs: Date.now) ||
            nextCheck < Date.now {
            return .now
        } else if months == 0 {
            return .soon
        } else {
            return .later
        }
    }
}
