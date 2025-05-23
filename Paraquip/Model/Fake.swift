//
//  Fake.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import Foundation
import CoreData

@MainActor
extension NSManagedObjectContext {
    static var preview: NSManagedObjectContext {
        CoreData.previewManagedObjectContext
    }
}

@MainActor
struct CoreData {
    
    private static let fake: (NSPersistentContainer, Profile) = createFakePersistentContainer()

    static var inMemoryPersistentContainer: NSPersistentContainer { fake.0 }
    static var previewManagedObjectContext: NSManagedObjectContext { inMemoryPersistentContainer.viewContext }
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
        let dummyPDFURL = Bundle.main.url(forResource: "Dummy", withExtension: "pdf")
        let dummyImageURL = Bundle.main.url(forResource: "Dummy", withExtension: "jpg")

        let calender = Calendar.current
        let oneYearAgo = calender.date(byAdding: .year, value: -1, to: .paraquipNow)!

        let profile = Profile.create(context: context)
        profile.name = LocalizedString("Your Equipment")
        profile.pilotWeight = 70
        profile.additionalWeight = 10
        profile.desiredWingLoad = 4.5
        profile.profileIcon = .default

        do {
            let equipment = Equipment.reserve(context: context)
            equipment.brand = "Nova"
            equipment.name = "Beamer 3 light"
            equipment.checkCycle = 3
            equipment.purchaseLog = LogEntry.create(context: context, date: oneYearAgo)
            equipment.weight = 1.37
            equipment.maxWeight = 130
            profile.addToEquipment(equipment)
        }

        do {
            let equipment = Equipment.reserve(context: context)
            equipment.brand = "Ozone"
            equipment.name = "Angel SQ"
            equipment.checkCycle = 3
            equipment.purchaseLog = LogEntry.create(context: context, date: oneYearAgo)
            equipment.weight = 1.54
            equipment.maxWeight = 120
            profile.addToEquipment(equipment)

            let threeMonthsAgo = calender.date(byAdding: .month, value: -3, to: .paraquipNow)!
            equipment.addToCheckLog(LogEntry.create(context: context,
                                                    date: calender.date(byAdding: .day, value: 8, to: threeMonthsAgo)!))
        }

        do {
            let equipment = Equipment.harness(context: context)
            equipment.brand = "Woody Valley"
            equipment.name = "Wani Light 2"
            equipment.checkCycle = 12
            equipment.purchaseLog = LogEntry.create(context: context, date: oneYearAgo)
            equipment.equipmentSize = "M"
            equipment.weight = 2.75
            profile.addToEquipment(equipment)

            equipment.addToCheckLog(LogEntry.create(context: context,
                                                    date: calender.date(byAdding: .month, value: -5, to: .paraquipNow)!))
        }

        do {
            let equipment = Equipment.paraglider(context: context)
            equipment.brand = "Gin"
            equipment.name = "Explorer 2"
            equipment.equipmentSize = "S"
            equipment.checkCycle = 12
            equipment.projectedAreaValue = 20.43
            equipment.purchaseLog = LogEntry.create(context: context, date: oneYearAgo)
            equipment.weight = 3.7
            equipment.minWeightValue = 75
            equipment.maxWeightValue = 95
            equipment.minRecommendedWeightValue = 80
            equipment.maxRecommendedWeightValue = 90
            if let dummyPDFURL {
                equipment.manualAttachment = createAttachment(for: dummyPDFURL, context: context)
            }
            profile.addToEquipment(equipment)

            let logEntry = LogEntry.create(context: context, date: calender.date(byAdding: .day, value: -40, to: .paraquipNow)!)
            if let dummyPDFURL, let dummyImageURL {
                logEntry.addToAttachments(createAttachment(for: dummyPDFURL, context: context))
                logEntry.addToAttachments(createAttachment(for: dummyImageURL, context: context))
            }
            equipment.addToCheckLog(logEntry)
        }

        do {
            let equipment = Equipment.gear(context: context)
            equipment.brand = "Woody Valley"
            equipment.name = "Rucksack Light"
            equipment.purchaseLog = LogEntry.create(context: context, date: oneYearAgo)
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
            let equipment = Equipment.paraglider(context: context)
            equipment.brand = "Gin"
            equipment.name = "Calypso"
            equipment.equipmentSize = "M"
            equipment.checkCycle = 12
            equipment.addToCheckLog(LogEntry.create(context: context,
                                                    date: calender.date(byAdding: .month, value: -6, to: .paraquipNow)!))
            profile2.addToEquipment(equipment)
        }

        try! context.save()

        return profile
    }

    private static func createAttachment(for url: URL, context: NSManagedObjectContext) -> Attachment {
        let attachment = Attachment(context: context)
        attachment.filePath = url.lastPathComponent
        attachment.timestamp = Date.paraquipNow

        try? FileManager.default.copyItem(at: url, to: attachment.fileURL!)

        return attachment
    }

    static func fakeLogEntry(isPurchase: Bool, hasAttachment: Bool = false) -> LogEntry {
        let logEntry = LogEntry.create(context: .preview)
        if isPurchase {
            CoreData.fakeProfile.allEquipment.first?.purchaseLog = logEntry
        }
        if hasAttachment {
            logEntry.addToAttachments(Attachment(context: .preview))
        }
        return logEntry
    }
}

