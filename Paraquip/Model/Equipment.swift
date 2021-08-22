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
    var checkLog: [Check] { get }
    var purchaseDate: Date? { get set }
}

struct Check: Identifiable {
    var id = UUID()
    var date: Date
}

enum CheckUrgency {
    case now
    case soon(Date)
    case later(Date)
    case never
}

extension Equipment {

    var lastCheck: Date? {
        checkLog.first?.date ?? purchaseDate
    }

    var nextCheck: Date? {
        guard checkCycle > 0 else {
            return nil
        }

        guard let lastCheck = lastCheck else {
            return Date.now
        }

        return Calendar.current.date(byAdding: .month,
                                     value: checkCycle,
                                     to: lastCheck)!
    }

    var checkUrgency: CheckUrgency {
        guard let nextCheck = nextCheck else {
            return .never
        }

        let months = Calendar.current.dateComponents([.month], from: Date.now, to: nextCheck).month ?? 0

        if Calendar.current.isDate(nextCheck, inSameDayAs: Date.now) ||
            nextCheck < Date.now {
            return .now
        } else if months == 0 {
            return .soon(nextCheck)
        } else {
            return .later(nextCheck)
        }
    }
}

extension Array where Element == Check {
    func sorted() -> [Element] {
        return sorted { check1, check2 in
            return check1.date > check2.date
        }
    }
}

extension CheckModel {
    func toModel() -> Check {
        Check(id: id!, date: date!)
    }
}
