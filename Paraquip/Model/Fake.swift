//
//  Fake.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import Foundation
import CoreData

struct CoreData {
    
    private static let fake: (NSPersistentContainer, Profile) = createFakePersistentContainer()

    static var inMemoryPersistentContainer: NSPersistentContainer { fake.0 }
    static var previewContext: NSManagedObjectContext { inMemoryPersistentContainer.viewContext }
    static var fakeProfile: Profile { fake.1 }

    private static func createFakePersistentContainer() -> (NSPersistentContainer, Profile) {
        let container = NSPersistentContainer(name: "Model")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        return (container, createFakeProfile(context: container.viewContext))
    }

    private static func createFakeProfile(context: NSManagedObjectContext) -> Profile {
        let dummyPDFURL = Bundle.main.url(forResource: "Dummy", withExtension: "pdf")!
        let dummyImageURL = Bundle.main.url(forResource: "Dummy", withExtension: "jpg")!

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "de")

        let profile = Profile.create(context: context)
        profile.name = LocalizedString("Your Equipment")
        profile.pilotWeight = 70
        profile.additionalWeight = 10
        profile.desiredWingLoad = 4.5
        profile.profileIcon = .default

        do {
            let equipment = Reserve.create(context: context)
            equipment.brand = "Nova"
            equipment.name = "Beamer 3 light"
            equipment.checkCycle = 3
            equipment.purchaseLog = LogEntry.create(context: context,
                                                    date: dateFormatter.date(from: "30.09.2020")!)
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
            let equipment = Reserve.create(context: context)
            equipment.brand = "Ozone"
            equipment.name = "Angel SQ"
            equipment.checkCycle = 3
            equipment.purchaseLog = LogEntry.create(context: context,
                                                    date: dateFormatter.date(from: "30.09.2020")!)
            equipment.weight = 1.54
            equipment.weightRange = {
                let weightRange = WeightRange(context: context)
                weightRange.min = 0
                weightRange.max = 120
                return weightRange
            }()
            profile.addToEquipment(equipment)

            equipment.addToCheckLog(LogEntry.create(context: context,
                                                    date: dateFormatter.date(from: "10.07.2021")!))
        }

        do {
            let equipment = Harness.create(context: context)
            equipment.brand = "Woody Valley"
            equipment.name = "Wani Light 2"
            equipment.checkCycle = 12
            equipment.purchaseLog = LogEntry.create(context: context,
                                                    date: dateFormatter.date(from: "30.09.2020")!)
            equipment.equipmentSize = "M"
            equipment.weight = 2.75
            profile.addToEquipment(equipment)

            equipment.addToCheckLog(LogEntry.create(context: context,
                                                    date: dateFormatter.date(from: "14.04.2021")!))
        }

        do {
            let equipment = Paraglider.create(context: context)
            equipment.brand = "Gin"
            equipment.name = "Explorer 2"
            equipment.equipmentSize = "S"
            equipment.checkCycle = 12
            equipment.projectedAreaMeasurement = .init(value: 20.43, unit: .squareMeters)
            equipment.purchaseLog = LogEntry.create(context: context,
                                                    date: dateFormatter.date(from: "30.09.2020")!)
            equipment.weight = 3.7
            equipment.weightRange = {
                let weightRange = WeightRange(context: context)
                weightRange.min = 75
                weightRange.max = 95
                return weightRange
            }()
            equipment.manualAttachment = createAttachment(for: dummyPDFURL, context: context)
            profile.addToEquipment(equipment)

            let logEntry = LogEntry.create(context: context, date: dateFormatter.date(from: "12.08.2021")!)
            logEntry.addToAttachments(createAttachment(for: dummyPDFURL, context: context))
            logEntry.addToAttachments(createAttachment(for: dummyImageURL, context: context))
            equipment.addToCheckLog(logEntry)
        }

        do {
            let equipment = Gear.create(context: context)
            equipment.brand = "Woody Valley"
            equipment.name = "Rucksack Light"
            equipment.purchaseLog = LogEntry.create(context: context,
                                                    date: dateFormatter.date(from: "30.09.2020")!)
            equipment.equipmentSize = "M"
            equipment.weight = 1.05
            profile.addToEquipment(equipment)
        }
        
        let profile2 = Profile.create(context: context)
        profile2.name = LocalizedString("Dune Flying")
        profile2.pilotWeight = 70
        profile2.additionalWeight = 10
        profile2.profileIcon = .beach

        do {
            let equipment = Paraglider.create(context: context)
            equipment.brand = "Gin"
            equipment.name = "Calypso"
            equipment.equipmentSize = "M"
            profile2.addToEquipment(equipment)
        }

        return profile
    }

    private static func createAttachment(for url: URL, context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(context: context)
        attachment.filePath = url.lastPathComponent
        attachment.timestamp = Date.paraquipNow

        try? FileManager.default.copyItem(at: url, to: attachment.fileURL!)

        return attachment
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
