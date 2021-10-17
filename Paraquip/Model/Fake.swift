//
//  Fake.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import Foundation
import CoreData

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
        profile.name = "Equipment"
        profile.profileIcon = .default

        do {
            let equipment = Reserve(context: context)
            equipment.id = UUID()
            equipment.brand = "Nova"
            equipment.brandId = "nova"
            equipment.name = "Beamer 3 light"
            equipment.checkCycle = 3
            equipment.purchaseDate = dateFormatter.date(from: "30.09.2020")!
            profile.addToEquipment(equipment)
        }

        do {
            let equipment = Reserve(context: context)
            equipment.id = UUID()
            equipment.brand = "Ozone"
            equipment.brandId = "ozone"
            equipment.name = "Angel SQ"
            equipment.checkCycle = 3
            equipment.purchaseDate = dateFormatter.date(from: "30.09.2020")!
            profile.addToEquipment(equipment)

            let check = Check(context: context)
            check.id = UUID()
            check.date = dateFormatter.date(from: "10.07.2021")!
            equipment.addToCheckLog(check)
        }

        do {
            let equipment = Harness(context: context)
            equipment.id = UUID()
            equipment.brand = "Woody Valley"
            equipment.brandId = "woody-valley"
            equipment.name = "Wani Light 2"
            equipment.checkCycle = 12
            equipment.purchaseDate = dateFormatter.date(from: "30.09.2020")!
            profile.addToEquipment(equipment)

            let check = Check(context: context)
            check.id = UUID()
            check.date = dateFormatter.date(from: "14.04.2021")!
            equipment.addToCheckLog(check)
        }

        do {
            let equipment = Paraglider(context: context)
            equipment.id = UUID()
            equipment.brand = "Gin"
            equipment.brandId = "gin"
            equipment.name = "Explorer 2"
            equipment.equipmentSize = .small
            equipment.checkCycle = 12
            equipment.purchaseDate = dateFormatter.date(from: "30.09.2020")!
            profile.addToEquipment(equipment)

            let check = Check(context: context)
            check.id = UUID()
            check.date = dateFormatter.date(from: "12.08.2021")!
            equipment.addToCheckLog(check)
        }

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
