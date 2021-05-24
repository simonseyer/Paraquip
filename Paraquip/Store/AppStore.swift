//
//  AppStore.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import Foundation
import Combine

struct ProfileIdentifier: Identifiable, Hashable {
    var id: UUID
    var name: String

    fileprivate init(profile: Profile) {
        self.id = profile.id
        self.name = profile.name
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

class AppStore: ObservableObject {

    private let persistence: AppPersistence

    private var storedProfiles: [ProfileIdentifier: ProfileStore] = [:] {
        didSet {
            profiles = Array(storedProfiles.keys)
            save()
        }
    }

    @Published private(set) var profiles: [ProfileIdentifier] = []

    init(persistence: AppPersistence = .init()) {
        self.persistence = persistence

        var profileStores = persistence
            .load()?
            .compactMap { ProfileStore(id: $0) }
            ?? []

        if profileStores.isEmpty {
            profileStores.append(ProfileStore(profile: Profile(name: "Paraquip")))
        }

        storedProfiles = profileStores.reduce(into: [ProfileIdentifier: ProfileStore]()) {
            $0[ProfileIdentifier(profile: $1.profile)] = $1
        }
        profiles = Array(storedProfiles.keys)
        save()
    }

    private func save() {
        persistence.save(profiles: storedProfiles.keys.map { $0.id })
    }

    func profileStore(for identifier: ProfileIdentifier) -> ProfileStore? {
        return storedProfiles[identifier]
    }

    func createProfile(name: String) -> ProfileStore {
        let newProfile = Profile(name: name)
        let store = ProfileStore(profile: newProfile)
        storedProfiles[ProfileIdentifier(profile: newProfile)] = store
        return store
    }

    func delete(profile: ProfileIdentifier) {
        storedProfiles[profile] = nil
    }

    func store(for profileIdentifier: ProfileIdentifier) -> ProfileStore? {
        return storedProfiles[profileIdentifier]
    }
}

