//
//  AppStore.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import Foundation
import Combine
import CoreData

struct ProfileIdentifier: Identifiable, Hashable {
    var id: UUID
    var name: String

    fileprivate init(profile: ProfileModel) {
        self.id = profile.id!
        self.name = profile.name!
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

class AppStore: ObservableObject {

    private var storedProfiles: [ProfileIdentifier: ProfileStore] = [:] {
        didSet {
            profiles = Array(storedProfiles.keys)
        }
    }

    @Published private(set) var profiles: [ProfileIdentifier] = []

    private let persistentContainer: NSPersistentContainer

    static var shared: AppStore = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return AppStore(persistentContainer: container)
    }()

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        let profileStores: [(ProfileIdentifier, ProfileStore)] = Self
            .loadProfiles(context: persistentContainer.viewContext)
            .compactMap {
                let store = CoreDataProfileStore(profile: $0, persistentContainer: persistentContainer)
                return (ProfileIdentifier(profile: $0), store)
            }

        if profileStores.isEmpty {
            _ = createProfile(name: "Paraquip")
        } else {
            storedProfiles = .init(uniqueKeysWithValues: profileStores)
            profiles = Array(storedProfiles.keys)
        }
    }

    private static func loadProfiles(context: NSManagedObjectContext) -> [ProfileModel] {
        let fetchRequest: NSFetchRequest<ProfileModel> = ProfileModel.fetchRequest()
        let results = (try? context.fetch(fetchRequest)) ?? []
        return results
    }

    func profileStore(for identifier: ProfileIdentifier) -> ProfileStore? {
        return storedProfiles[identifier]
    }

    func createProfile(name: String) -> ProfileStore {
        let model = ProfileModel(context: persistentContainer.viewContext)
        model.name = name
        model.id = UUID()
        try? persistentContainer.viewContext.save()

        let store = CoreDataProfileStore(profile: model, persistentContainer: persistentContainer)
        storedProfiles[ProfileIdentifier(profile: model)] = store
        return store
    }

    func delete(profile: ProfileIdentifier) {
        storedProfiles[profile] = nil
    }

    func store(for profileIdentifier: ProfileIdentifier) -> ProfileStore? {
        return storedProfiles[profileIdentifier]
    }
}

extension AppStore {
    var mainProfileStore: ProfileStore {
        store(for: profiles.first!)!
    }
}
