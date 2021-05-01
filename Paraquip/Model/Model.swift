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
    var reserves: [Reserve] = []

    var equipment: [Equipment] {
        return paragliders + reserves
    }
}

protocol Equipment: Codable {
    var id: UUID { get set }
    var brand: String { get set }
    var name: String { get set }
    var checkCycle: Int { get set }
    var checkLog: [Check] { get set }
}

//struct AnyEquipment<T : Equipment>: Equipment {
//
//    private var equipment: T
//
//    var id: UUID {
//        get { equipment.id }
//        set { equipment.id = newValue }
//    }
//
//    var brand: String {
//        get { equipment.brand }
//        set { equipment.brand = newValue }
//    }
//
//    var name: String {
//        get { equipment.name }
//        set { equipment.name = newValue }
//    }
//
//    var checkCycle: Int {
//        get { equipment.checkCycle }
//        set { equipment.checkCycle = newValue }
//    }
//
//    var checkLog: [Check] {
//        get { equipment.checkLog }
//        set { equipment.checkLog = newValue }
//    }
//
//    init(_ equipment: T) {
//        self.equipment = equipment
//    }
//}

extension Equipment {
    var nextCheck: Date {
        guard let lastCheck = checkLog.last?.date else {
            return Date()
        }

        return Calendar.current.date(byAdding: .month,
                                     value: checkCycle,
                                     to: lastCheck)!
    }

//    func eraseToAnyEquipment() -> AnyEquipment<Self> {
//        return AnyEquipment(self)
//    }
}

struct Paraglider: Equipment, Identifiable {
    var id = UUID()
    var brand: String
    var name: String
    var size: String
    var checkCycle: Int
    var checkLog: [Check] = []
}

extension Paraglider {
    static func new() -> Paraglider {
        return Paraglider(brand: "", name: "", size: "M", checkCycle: 6)
    }
}

struct Reserve: Equipment, Identifiable {
    var id = UUID()
    var brand: String
    var name: String
    var checkCycle: Int
    var checkLog: [Check] = []
}

extension Reserve {
    static func new() -> Reserve {
        return Reserve(brand: "", name: "", checkCycle: 3)
    }
}

struct Check: Codable, Identifiable {
    var id = UUID()
    var date: Date
}
