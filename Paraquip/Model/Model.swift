//
//  Model.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import Foundation

struct Profile: Codable, Identifiable {
    var id = UUID()
    var name: String
    var paragliders: [Paraglider] = []

    var equipment: [Equipment] {
        return paragliders
    }
}

protocol Equipment: Codable {
    var id: UUID { get }
    var brand: String { get }
    var name: String { get }
    var checkCycle: Int { get }
    var checkLog: [Check] { get }
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

struct Paraglider: Equipment, Identifiable {
    var id = UUID()
    var brand: String
    var name: String
    var size: String
    var checkCycle: Int
    var checkLog: [Check] = []
}

struct Check: Codable, Identifiable {
    var id = UUID()
    var date: Date
}
