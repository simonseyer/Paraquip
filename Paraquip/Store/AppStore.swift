//
//  AppStore.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import Foundation
import Combine
import CoreData

fileprivate struct ProfileIdentifier: Identifiable, Hashable {
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

protocol AppStore {
    var mainProfileStore: ProfileStore { get }
}

class CoreDataAppStore: AppStore {

    private var storedProfiles: [ProfileIdentifier: ProfileStore] = [:]
    private let persistentContainer: NSPersistentContainer

    var mainProfileStore: ProfileStore {
        return storedProfiles.values.first!
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
        }
    }

    private static func loadProfiles(context: NSManagedObjectContext) -> [ProfileModel] {
        let fetchRequest: NSFetchRequest<ProfileModel> = ProfileModel.fetchRequest()
        let results = (try? context.fetch(fetchRequest)) ?? []
        return results
    }

    private func createProfile(name: String) -> ProfileStore {
        let model = ProfileModel(context: persistentContainer.viewContext)
        model.name = name
        model.id = UUID()
        try? persistentContainer.viewContext.save()

        let store = CoreDataProfileStore(profile: model, persistentContainer: persistentContainer)
        storedProfiles[ProfileIdentifier(profile: model)] = store
        return store
    }
}

class FakeAppStore: AppStore {
    let mainProfileStore: ProfileStore = FakeProfileStore(profile: .fake())
}
