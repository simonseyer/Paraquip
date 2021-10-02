//
//  AppStore.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import Foundation
import Combine
import CoreData

protocol AppStore {
    var profiles: CurrentValueSubject<[Profile.Description], Never> { get }
    var mainProfileStore: ProfileStore { get }

    func store(profile: Profile.Description)
    func remove(profile: Profile.Description)

    func store(for profile: Profile.Description) -> ProfileStore?

    func allEquipment() -> [Equipment]
}

class CoreDataAppStore: AppStore {

    private var profileStores: [UUID: ProfileStore] = [:]
    private let persistentContainer: NSPersistentContainer
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // TODO: fix sorting
    let profiles: CurrentValueSubject<[Profile.Description], Never>

    // TODO: handle no profiles
    var mainProfileStore: ProfileStore {
        return store(for: profiles.value.first!)!
    }

    convenience init() {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        self.init(persistentContainer: container)
    }

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        let allProfiles = ProfileModel
            .fetchAll(context: persistentContainer.viewContext)
            .map { $0.profileDescription }
        profiles =  CurrentValueSubject(allProfiles)

        if allProfiles.isEmpty {
            store(profile: .init(name: "Paraquip", icon: .default))
        }
    }

    private func save() {
        try? context.save()

        profiles.value = ProfileModel
            .fetchAll(context: persistentContainer.viewContext)
            .map { $0.profileDescription }
    }

    func store(profile: Profile.Description) {
        let model: ProfileModel = {
            if let profileModel = ProfileModel.fetch(profile, context: context) {
                return profileModel
            } else {
               return ProfileModel(context: context)
            }
        }()

        model.id = profile.id
        model.name = profile.name
        model.icon = profile.icon.rawValue

        save()
    }

    func remove(profile: Profile.Description) {
        guard let model = ProfileModel.fetch(profile, context: context) else {
            return
        }
        
        context.delete(model)
        save()
    }

    func allEquipment() -> [Equipment] {
        let fetchRequest: NSFetchRequest<EquipmentModel> = EquipmentModel.fetchRequest()
        return (try? context.fetch(fetchRequest).map { $0.toEquipmentModel() }) ?? []
    }

    func store(for profile: Profile.Description) -> ProfileStore? {
        if let store = profileStores[profile.id] {
            return store
        } else if let profileModel = ProfileModel.fetch(profile, context: context) {
            let store = CoreDataProfileStore(profile: profileModel, persistentContainer: persistentContainer)
            profileStores[profile.id] = store
            return store
        } else {
            return nil
        }
    }
}

extension ProfileModel {

    var profileDescription: Profile.Description {
        let profileIcon = Profile.Icon(rawValue: icon ?? "") ?? .default
        return .init(id: id!, name: name!, icon: profileIcon)
    }

    static func fetch(_ profile: Profile.Description, context: NSManagedObjectContext) -> ProfileModel? {
        let fetchRequest = ProfileModel.fetchRequest()
        fetchRequest.predicate = .init(format: "id == %@", profile.id.uuidString)
        fetchRequest.fetchLimit = 1
        return try? context.fetch(fetchRequest).first
    }

    static func fetchAll(context: NSManagedObjectContext) -> [ProfileModel] {
        let fetchRequest = ProfileModel.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }
}

class FakeAppStore: AppStore {
    let profiles = CurrentValueSubject<[Profile.Description], Never>([Profile.Description(name: "Paraquip", icon: .default)])
    let mainProfileStore: ProfileStore = FakeProfileStore(profile: .fake())

    func store(profile: Profile.Description) {}
    func remove(profile: Profile.Description) {}
    
    func allEquipment() -> [Equipment] {
        mainProfileStore.profile.value.equipment
    }

    func store(for profile: Profile.Description) -> ProfileStore? {
        mainProfileStore
    }
}
