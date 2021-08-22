//
//  ProfileStore.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation
import CoreData
import Combine

protocol ProfileStore {
    var profile: CurrentValueSubject<Profile, Never> { get }

    func store(profile: Profile)

    func store(equipment: Equipment)
    func remove(equipment: [Equipment])

    func logCheck(at date: Date, for equipment: Equipment)
    func remove(checks: [Check], for equipment: Equipment)

    func attach(manual: Data, to equipment: Equipment)
    func loadManual(for equipment: Equipment) -> Data?
    func deleteManual(for equipment: Equipment)
}

class CoreDataProfileStore: ProfileStore {

    let profile: CurrentValueSubject<Profile, Never>

    private var profileModel: ProfileModel
    private let persistentContainer: NSPersistentContainer
    private var context: NSManagedObjectContext { persistentContainer.viewContext }

    init(profile: ProfileModel, persistentContainer: NSPersistentContainer) {
        self.profileModel = profile
        self.persistentContainer = persistentContainer
        self.profile = CurrentValueSubject(profile.toModel())
    }

    private func save() {
        try? context.save()
        profile.send(profileModel.toModel())
    }

    func store(profile: Profile) {
        profileModel.name = profile.name
        save()
    }

    func store(equipment: Equipment) {
        let model: EquipmentModel = {
            if let equipmentModel = EquipmentModel.fetch(equipment, context: context) {
                return equipmentModel
            } else {
                switch equipment {
                case is Paraglider:
                    let paragliderModel = ParagliderModel(context: context)
                    profileModel.addToParaglider(paragliderModel)
                    return paragliderModel
                case is Harness:
                    let harnessModel = HarnessModel(context: context)
                    profileModel.addToHarnesses(harnessModel)
                    return harnessModel
                case is Reserve:
                    let reserveModel = ReserveModel(context: context)
                    profileModel.addToReserves(reserveModel)
                    return reserveModel
                default:
                    fatalError("Unknown equipment type: \(type(of: equipment))")
                }
            }
        }()

        model.id = equipment.id
        model.name = equipment.name
        model.brand = equipment.brand.name
        model.brandId = equipment.brand.id
        model.checkCycle = Int16(equipment.checkCycle)
        model.purchaseDate = equipment.purchaseDate

        if let paraglider = equipment as? Paraglider,
           let paragliderModel = model as? ParagliderModel {
            paragliderModel.size = paraglider.size.rawValue
        }

        save()
    }

    func remove(equipment: [Equipment]) {
        let fetchRequest: NSFetchRequest<EquipmentModel> = EquipmentModel.fetchRequest()
        fetchRequest.predicate = .init(format: "id IN %@", equipment.map { return $0.id })
        let results = try? context.fetch(fetchRequest)

        for equipmentModel in results ?? [] {
            context.delete(equipmentModel)
        }

        save()
    }

    func logCheck(at date: Date, for equipment: Equipment) {
        guard let model = EquipmentModel.fetch(equipment, context: context) else {
            return
        }

        let checkModel = CheckModel(context: context)
        checkModel.id = UUID()
        checkModel.date = date
        model.addToCheckLog(checkModel)

        save()
    }

    func remove(checks: [Check], for equipment: Equipment) {
        let fetchRequest: NSFetchRequest<CheckModel> = CheckModel.fetchRequest()
        fetchRequest.predicate = .init(format: "id IN %@", checks.map { return $0.id })
        let results = try? context.fetch(fetchRequest)

        for checkModel in results ?? [] {
            context.delete(checkModel)
        }

        save()
    }

    func attach(manual: Data, to equipment: Equipment) {
        guard let equipmentModel = EquipmentModel.fetch(equipment, context: context) else {
            return
        }

        let manualModel = ManualModel(context: context)
        manualModel.data = manual
        equipmentModel.manual = manualModel

        save()
    }

    func loadManual(for equipment: Equipment) -> Data? {
        guard let equipmentModel = EquipmentModel.fetch(equipment, context: context) else {
            return nil
        }

        return equipmentModel.manual?.data
    }

    func deleteManual(for equipment: Equipment) {
        guard let equipmentModel = EquipmentModel.fetch(equipment, context: context),
              let manualModel = equipmentModel.manual else {
            return
        }

        context.delete(manualModel)
        save()
    }
}

extension EquipmentModel {
    static func fetch(_ equipment: Equipment, context: NSManagedObjectContext) -> EquipmentModel? {
        let fetchRequest: NSFetchRequest<EquipmentModel> = EquipmentModel.fetchRequest()
        fetchRequest.predicate = .init(format: "id == %@", equipment.id.uuidString)
        fetchRequest.fetchLimit = 1
        return try? context.fetch(fetchRequest).first
    }
}

class FakeProfileStore: ProfileStore {

    let profile: CurrentValueSubject<Profile, Never>

    init(profile: Profile) {
        self.profile = CurrentValueSubject(profile)
    }

    func store(profile: Profile) {}
    func store(equipment: Equipment) {}
    func remove(equipment: [Equipment]) {}
    func logCheck(at date: Date, for equipment: Equipment) {}
    func remove(checks: [Check], for equipment: Equipment) {}
    func attach(manual: Data, to equipment: Equipment) {}
    func loadManual(for equipment: Equipment) -> Data? { nil }
    func deleteManual(for equipment: Equipment) {}
}
