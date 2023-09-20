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
    var entries: [CheckEntry]
    var id: String { title }

    init(title: String, titleIcon: String? = nil, entries: [CheckEntry]) {
        self.title = title
        self.titleIcon = titleIcon
        self.entries = entries
    }
}

struct CheckEntry: Identifiable, Equatable {

    static func == (lhs: CheckEntry, rhs: CheckEntry) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.checkUrgency == rhs.checkUrgency
    }
    
    let id: UUID
    let name: String
    let checkUrgency: Equipment.CheckUrgency
    let onTap: () -> Void
}

private extension Calendar {
    func firstDayOfMonth(_ referenceDate: Date) -> Date {
        date(from: dateComponents([.year, .month], from: referenceDate))!
    }
}

extension CheckList {

    static let monthCount = 10

    init(equipment: [Equipment], onTap: @escaping (Equipment) -> Void) {
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
            let entry = CheckEntry(id: equipment.equipmentID,
                                   name: equipment.equipmentName,
                                   checkUrgency: equipment.checkUrgency,
                                   onTap: { onTap(equipment) })

            if case .now = equipment.checkUrgency {
                now.entries.append(entry)
            } else {
                let firstDayOfMonth = calendar.firstDayOfMonth(nextCheck)
                if months[firstDayOfMonth] != nil {
                    months[firstDayOfMonth]!.entries.append(entry)
                } else {
                    later.entries.append(entry)
                }
            }
        }

        sections = [now] + months.elements.map { $0.value } + [later]
    }
}
