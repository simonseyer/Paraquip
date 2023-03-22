//
//  LegacyAppPersistence.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import OSLog
import Versionable
import CoreData

class LegacyAppPersistence {

    private let basePath: URL
    private let fileManager: FileManager
    private let logger = Logger(category: "AppPersistence")

    private let decoder = JSONDecoder()

    private var url: URL {
        basePath.appendingPathComponent("app").appendingPathExtension("json")
    }

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.basePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func migrate(into managedObjectContext: NSManagedObjectContext) {
        guard let profileId = load()?.first,
              let profile = load(with: profileId) else {
            return
        }

        let profileModel = Profile.create(context: managedObjectContext, name: LocalizedString("Equipment"))
        profileModel.profileIcon = .default

        for paraglider in profile.paraglider {
            let paragliderModel = Paraglider.create(context: managedObjectContext)
            paragliderModel.name = paraglider.name
            paragliderModel.brand = paraglider.brand
            paragliderModel.brandId = paraglider.brandId
            paragliderModel.checkCycle = Int16(paraglider.checkCycle)
            paragliderModel.purchaseDate = paraglider.purchaseDate
            paragliderModel.size = paraglider.size
            profileModel.addToEquipment(paragliderModel)

            for check in paraglider.checkLog {
                let checkModel = LogEntry.create(context: managedObjectContext, date: check.date)
                paragliderModel.addToCheckLog(checkModel)
            }
        }

        for harness in profile.harnesses {
            let harnessModel = Harness.create(context: managedObjectContext)
            harnessModel.name = harness.name
            harnessModel.brand = harness.brand
            harnessModel.brandId = harness.brandId
            harnessModel.checkCycle = Int16(harness.checkCycle)
            harnessModel.purchaseDate = harness.purchaseDate
            profileModel.addToEquipment(harnessModel)

            for check in harness.checkLog {
                let checkModel = LogEntry.create(context: managedObjectContext, date: check.date)
                harnessModel.addToCheckLog(checkModel)
            }
        }

        for reserve in profile.reserves {
            let reserveModel = Reserve.create(context: managedObjectContext)
            reserveModel.name = reserve.name
            reserveModel.brand = reserve.brand
            reserveModel.brandId = reserve.brandId
            reserveModel.checkCycle = Int16(reserve.checkCycle)
            reserveModel.purchaseDate = reserve.purchaseDate
            profileModel.addToEquipment(reserveModel)

            for check in reserve.checkLog {
                let checkModel = LogEntry.create(context: managedObjectContext, date: check.date)
                reserveModel.addToCheckLog(checkModel)
            }
        }
        do {
            try managedObjectContext.save()
        } catch {
            logger.error("Failed to migrate data: \(error.description)")
        }

        let backupURL = url.appendingPathExtension("bak")
        try? fileManager.removeItem(at: backupURL)
        try? fileManager.moveItem(at: url, to: backupURL)
    }

    private func load() -> [UUID]? {
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([UUID].self, from: data)
        } catch {
            return nil
        }
    }

    func load(with id: UUID) -> PersistedProfile? {
        do {
            let url = basePath.appendingPathComponent(id.uuidString).appendingPathExtension("json")
            let data = try Data(contentsOf: url)
            let container = try decoder.decode(VersionableContainer<PersistedProfile>.self, from: data)
            return container.instance
        } catch {
            return nil
        }
    }
}
