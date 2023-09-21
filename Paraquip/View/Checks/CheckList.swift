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
}

struct CheckSection: Identifiable, Equatable {
    let title: String
    let titleIcon: String?
    var equipment: [Equipment]
    var id: String { title }

    init(title: String, titleIcon: String? = nil, entries: [Equipment]) {
        self.title = title
        self.titleIcon = titleIcon
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        dateFormatter.calendar = calendar

        var now = CheckSection(title: "Now", titleIcon: "hourglass", entries: [])
        var months: OrderedDictionary<Date, CheckSection> = [:]
        var later = CheckSection(title: "Later", titleIcon: "clock", entries: [])

        /// Initialize months with the next `monthCount` months (indexed by the first day of the month)
        let currentMonth = Date.paraquipNow
        for i in 0..<Self.monthCount {
            let month = calendar.date(byAdding: .month, value: i, to: currentMonth)!
            let firstDay = calendar.firstDayOfMonth(month)
            months[firstDay] = .init(title: dateFormatter.string(from: month), entries: [])
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
