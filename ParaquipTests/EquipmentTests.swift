//
//  EquipmentTests.swift
//  ParaquipTests
//
//  Created by Simon Seyer on 15.05.21.
//

import Testing
@testable import Paraquip
import CoreData

@MainActor
struct EquipmentTests {

    var persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = CoreData.inMemoryPersistentContainer
    }

    private func equipment(checkCycle: Int = 1, checkLog: [Date] = [], purchaseDate: Date? = nil) -> Equipment {
        let equipment = Equipment.reserve(context: persistentContainer.viewContext)
        equipment.checkCycle = Int16(checkCycle)

        if let purchaseDate {
            equipment.purchaseLog = LogEntry.create(context: persistentContainer.viewContext, date: purchaseDate)
        }

        for check in checkLog {
            equipment.addToCheckLog(LogEntry.create(context: persistentContainer.viewContext, date: check))
        }

        return equipment
    }

    func testNextCheck() {
        let equipment = equipment(checkLog: [Date.offsetBy(days: -40)])

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date.offsetBy(days: -40))!
        #expect(Calendar.current.isDate(equipment.nextCheck!, inSameDayAs: nextCheck))
    }

    func testNextCheckWithMultipleChecks() {
        let equipment = equipment(checkLog: [Date.offsetBy(days: -40), Date.offsetBy(days: 1)])

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date.offsetBy(days: 1))!
        #expect(Calendar.current.isDate(equipment.nextCheck!, inSameDayAs: nextCheck))
    }

    func testNextCheckWithPurchaseDate() {
        let equipment = equipment(purchaseDate: Date.offsetBy(days: 0))

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date.offsetBy(days: 0))!
        #expect(Calendar.current.isDate(equipment.nextCheck!, inSameDayAs: nextCheck))
    }

    func testNextCheckWithPurchaseDateAndCheck() {
        let equipment = equipment(checkLog: [Date.offsetBy(days: -40)],
                                  purchaseDate: Date.offsetBy(days: -60))

        let nextCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date.offsetBy(days: -40))!
        #expect(Calendar.current.isDate(equipment.nextCheck!, inSameDayAs: nextCheck))
    }

    func testNextCheckWithCheckOff() {
        let equipment = equipment(checkCycle: 0)
        #expect(equipment.nextCheck == nil)
    }
}
