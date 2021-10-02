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
    func updateContainedEquipment(_ equipment: [Equipment])

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

    private var subscriptions: Set<AnyCancellable> = []

    init(profile: ProfileModel, persistentContainer: NSPersistentContainer) {
        self.profileModel = profile
        self.persistentContainer = persistentContainer
        self.profile = CurrentValueSubject(profile.toModel())

        self.profileModel.publisher(for: \.self)
            .sink { model in print(model) }
            .store(in: &subscriptions)
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
                    return ParagliderModel(context: context)
                case is Harness:
                    return HarnessModel(context: context)
                case is Reserve:
                    return ReserveModel(context: context)
                default:
                    fatalError("Unknown equipment type: \(type(of: equipment))")
                }
            }
        }()

        profileModel.addToEquipment(model)
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
        for equipmentModel in EquipmentModel.fetch(equipment, context: context) {
            context.delete(equipmentModel)
        }
        save()
    }

    func updateContainedEquipment(_ equipment: [Equipment]) {
        let diff = equipment.difference(from: profile.value.equipment) { equipment1, equipment2 in
            equipment1.id == equipment2.id
        }

        var removedEquipment: [Equipment] = []
        var insertedEquipment: [Equipment] = []

        for change in diff {
          switch change {
          case let .remove(_, oldElement, _):
              removedEquipment.append(oldElement)
          case let .insert(_, newElement, _):
              insertedEquipment.append(newElement)
          }
        }

        for equipmentModel in EquipmentModel.fetch(removedEquipment, context: context) {
            profileModel.removeFromEquipment(equipmentModel)
        }

        for equipmentModel in EquipmentModel.fetch(insertedEquipment, context: context) {
            profileModel.addToEquipment(equipmentModel)
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

    static func fetch(_ equipment: [Equipment], context: NSManagedObjectContext) -> [EquipmentModel] {
        let fetchRequest: NSFetchRequest<EquipmentModel> = EquipmentModel.fetchRequest()
        fetchRequest.predicate = .init(format: "id IN %@", equipment.map { return $0.id })
        return (try? context.fetch(fetchRequest)) ?? []
    }
}

extension ProfileModel {
    func addToEquipment(_ value: EquipmentModel) {
        if let equipment = value as? ParagliderModel {
            addToParaglider(equipment)
        } else if let equipment = value as? ReserveModel {
            addToReserves(equipment)
        } else if let equipment = value as? HarnessModel {
            addToHarnesses(equipment)
        } else {
            fatalError("Unknown equipment type")
        }
    }

    func removeFromEquipment(_ value: EquipmentModel) {
        if let equipment = value as? ParagliderModel {
            removeFromParaglider(equipment)
        } else if let equipment = value as? ReserveModel {
            removeFromReserves(equipment)
        } else if let equipment = value as? HarnessModel {
            removeFromHarnesses(equipment)
        } else {
            fatalError("Unknown equipment type")
        }
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
    func updateContainedEquipment(_ equipment: [Equipment]) {}
    func logCheck(at date: Date, for equipment: Equipment) {}
    func remove(checks: [Check], for equipment: Equipment) {}
    func attach(manual: Data, to equipment: Equipment) {}
    func loadManual(for equipment: Equipment) -> Data? { nil }
    func deleteManual(for equipment: Equipment) {}
}
