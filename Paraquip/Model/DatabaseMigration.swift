//
//  DatabaseMigration.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.03.23.
//

import Foundation
import CoreData
import OSLog

@MainActor
class DatabaseMigration: ObservableObject {
    @Published private(set) var hasRemovedDuplicateEquipment = false

    private let logger = Logger(category: "DatabaseMigration")

    func run(context: NSManagedObjectContext) {
        let profilesFetchRequest = Profile.fetchRequest()
        let profiles = (try? context.fetch(profilesFetchRequest)) ?? []

        let equipmentFetchRequest = Equipment.fetchRequest()
        let equipment = (try? context.fetch(equipmentFetchRequest)) ?? []

        for equipment in equipment {
            if equipment.type == 0 {
                equipment.type = Equipment.EquipmentType.type(for: equipment).rawValue
            }

            if let purchaseDate = equipment.purchaseDate, equipment.purchaseLog == nil {
                equipment.purchaseLog = LogEntry.create(context: context, date: purchaseDate)
                equipment.purchaseDate = nil
            }

            if let manualData = equipment.manual?.data {
                equipment.manualAttachment = Attachment.create(data: manualData,
                                                               fileName: LocalizedString("Manual.pdf"),
                                                               context: context)
                equipment.manual = nil
            }

            if let weightRange = equipment.weightRange {
                equipment.minWeight = weightRange.min
                equipment.maxWeight = weightRange.max
                context.delete(weightRange)

                if equipment.minWeightValue == 0 {
                    equipment.minWeight = nil
                }
            }
        }

        if profiles.count == 1,
           let profile = profiles.first,
           profile.name == "Paraquip",
           profile.equipment?.count ?? 0 == 0 {
            profile.name = LocalizedString("Your Equipment")

            for equipment in equipment {
                profile.addToEquipment(equipment)
            }
        }

        var hasRemovedEquipment = false
        for profile in profiles {
            hasRemovedEquipment = removeDuplicateEquipment(from: profile, type: .paraglider) || hasRemovedEquipment
            hasRemovedEquipment = removeDuplicateEquipment(from: profile, type: .harness) || hasRemovedEquipment
        }
        Task {
            self.hasRemovedDuplicateEquipment = hasRemovedEquipment
        }

        do {
            try context.save()
        } catch {
            logger.error("Failed to migrate database from v0 to v1: \(error.description)")
        }
    }

    private func removeDuplicateEquipment(from profile: Profile, type: Equipment.EquipmentType) -> Bool {
        let equipment = profile.allEquipment.filter { $0.equipmentType == type }
        if equipment.count > 1 {
            for equipment in equipment.dropFirst() {
                logger.log("Removed equipment '\(equipment.equipmentName)' from profile '\(profile.profileName)' because it had more than one \(type.localizedNameString)")
                equipment.removeFromProfiles(profile)
            }
            return true
        }
        return false
    }
}
