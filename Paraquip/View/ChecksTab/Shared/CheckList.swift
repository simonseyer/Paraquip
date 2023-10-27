//
//  CheckList.swift
//  Paraquip
//
//  Created by Simon Seyer on 20.09.23.
//

import Foundation
import OrderedCollections

struct CheckList: Equatable {
    var sections: [CheckSection]
    var isEmpty: Bool {
        for section in sections {
            if !section.equipment.isEmpty {
                return false
            }
        }
        return true
    }
}

struct CheckSection: Identifiable, Equatable {
    enum Title: Equatable, Hashable {
        case month(Date)
        case now
        case later
    }

    let title: Title
    var equipment: [Equipment]
    var id: Title { title }

    init(title: Title, entries: [Equipment]) {
        self.title = title
        self.equipment = entries
    }
}

private extension Calendar {
    func firstDayOfMonth(_ referenceDate: Date) -> Date {
        date(from: dateComponents([.year, .month], from: referenceDate))!
    }
}

extension CheckList {

    static let monthCount = 10

    init(equipment: [Equipment]) {
        let calendar = Calendar.current
        var now = CheckSection(title: .now, entries: [])
        var months: OrderedDictionary<Date, CheckSection> = [:]
        var later = CheckSection(title: .later, entries: [])

        /// Initialize months with the next `monthCount` months (indexed by the first day of the month)
        let currentMonth = Date.paraquipNow
        for i in 0..<Self.monthCount {
            let month = calendar.date(byAdding: .month, value: i, to: currentMonth)!
            let firstDay = calendar.firstDayOfMonth(month)
            months[firstDay] = .init(title: .month(month), entries: [])
        }

        /// Sort equipment by next check date
        let sortedEquipment = equipment.sorted { e1, e2 in
            e1.nextCheck ?? .distantPast < e2.nextCheck ?? .distantPast
        }

        for equipment in sortedEquipment {
            guard let nextCheck = equipment.nextCheck else { continue }
            if case .now = equipment.checkUrgency {
                now.equipment.append(equipment)
            } else {
                let firstDayOfMonth = calendar.firstDayOfMonth(nextCheck)
                if months[firstDayOfMonth] != nil {
                    months[firstDayOfMonth]!.equipment.append(equipment)
                } else {
                    later.equipment.append(equipment)
                }
            }
        }

        sections = [now] + months.elements.map { $0.value } + [later]
    }
}
