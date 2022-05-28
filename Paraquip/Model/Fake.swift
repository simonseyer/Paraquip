//
//  Fake.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import Foundation
import CoreData
import UIKit

struct CoreData {
    static let inMemoryPersistentContainer: NSPersistentContainer = .fake(name: "Model")

    static var previewContext: NSManagedObjectContext {
        inMemoryPersistentContainer.viewContext
    }

    static var fakeProfile: Profile {
        return inMemoryPersistentContainer.createFakeProfile()
    }
}

extension NSPersistentContainer {
    static func fake(name: String) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }

            _ = container.createFakeProfile()
        }

        return container
    }

    func createFakeProfile() -> Profile {
        let context = viewContext

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "de")

        let profile = Profile(context: context)
        profile.id = UUID()
        profile.name = "Your Equipment"
        profile.pilotWeight = 70
        profile.additionalWeight = 10
        profile.profileIcon = .default

        do {
            let equipment = Reserve(context: context)
            equipment.id = UUID()
            equipment.brand = "Nova"
            equipment.brandId = "nova"
            equipment.name = "Beamer 3 light"
            equipment.checkCycle = 3
            equipment.purchaseLog = LogEntry.create(context: context, date: dateFormatter.date(from: "30.09.2020")!)
            equipment.weight = 1.37
            equipment.weightRange = {
                let weightRange = WeightRange(context: context)
                weightRange.min = 0
                weightRange.max = 130
                return weightRange
            }()
            profile.addToEquipment(equipment)
        }

        do {
            let equipment = Reserve(context: context)
            equipment.id = UUID()
            equipment.brand = "Ozone"
            equipment.brandId = "ozone"
            equipment.name = "Angel SQ"
            equipment.checkCycle = 3
            equipment.purchaseLog = LogEntry.create(context: context, date: dateFormatter.date(from: "30.09.2020")!)
            equipment.weight = 1.54
            equipment.weightRange = {
                let weightRange = WeightRange(context: context)
                weightRange.min = 0
                weightRange.max = 120
                return weightRange
            }()
            profile.addToEquipment(equipment)

            let logEntry = LogEntry(context: context)
            logEntry.id = UUID()
            logEntry.date = dateFormatter.date(from: "10.07.2021")!
            equipment.addToCheckLog(logEntry)
        }

        do {
            let equipment = Harness(context: context)
            equipment.id = UUID()
            equipment.brand = "Woody Valley"
            equipment.brandId = "woody-valley"
            equipment.name = "Wani Light 2"
            equipment.checkCycle = 12
            equipment.purchaseLog = LogEntry.create(context: context, date: dateFormatter.date(from: "30.09.2020")!)
            equipment.equipmentSize = .medium
            equipment.weight = 2.75
            profile.addToEquipment(equipment)

            let logEntry = LogEntry(context: context)
            logEntry.id = UUID()
            logEntry.date = dateFormatter.date(from: "14.04.2021")!
            equipment.addToCheckLog(logEntry)
        }

        do {
            let equipment = Paraglider(context: context)
            equipment.id = UUID()
            equipment.brand = "Gin"
            equipment.brandId = "gin"
            equipment.name = "Explorer 2"
            equipment.equipmentSize = .small
            equipment.checkCycle = 12
            equipment.purchaseLog = LogEntry.create(context: context, date: dateFormatter.date(from: "30.09.2020")!)
            equipment.weight = 3.7
            equipment.weightRange = {
                let weightRange = WeightRange(context: context)
                weightRange.min = 75
                weightRange.max = 95
                return weightRange
            }()
            profile.addToEquipment(equipment)

            let logEntry = LogEntry(context: context)
            logEntry.id = UUID()
            logEntry.date = dateFormatter.date(from: "12.08.2021")!
            equipment.addToCheckLog(logEntry)

            let dummyPDFURL = Bundle.main.url(forResource: "Dummy", withExtension: "pdf")!
            try? FileManager.default.copyItem(at: dummyPDFURL, to: FileManager.default.attachmentsDirectory.appendingPathComponent(dummyPDFURL.lastPathComponent))

            let attachment = LogAttachment(context: context)
            attachment.filePath = dummyPDFURL.lastPathComponent
            attachment.timestamp = Date.paraquipNow
            logEntry.addToAttachments(attachment)

            let dummyImageURL = Bundle.main.url(forResource: "Dummy", withExtension: "jpg")!
            try? FileManager.default.copyItem(at: dummyImageURL, to: FileManager.default.attachmentsDirectory.appendingPathComponent(dummyImageURL.lastPathComponent))

            let attachment2 = LogAttachment(context: context)
            attachment2.filePath = dummyImageURL.lastPathComponent
            attachment2.timestamp = Date.paraquipNow
            logEntry.addToAttachments(attachment2)
        }

        try! context.save()

        return profile
    }
}

extension NotificationState {
    static func fake() -> NotificationState {
        return NotificationState(
            isEnabled: true,
            wasRequestRejected: false,
            configuration: [
                NotificationConfig(unit: .months, multiplier: 1),
                NotificationConfig(unit: .days, multiplier: 10)
            ]
        )
    }
}
