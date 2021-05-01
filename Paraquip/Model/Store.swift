//
//  Store.swift
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

class Store: ObservableObject {

    private var storedProfiles: [ProfileIdentifier: ProfileStore] = [:] {
        didSet {
            profiles = Array(storedProfiles.keys)
        }
    }

    @Published var profiles: [ProfileIdentifier] = []

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

class ProfileStore: ObservableObject {

    @Published var profile: Profile

    init(profile: Profile) {
        self.profile = profile
    }

    func update(name: String) {
        profile.name = name
    }

    func store(equipment: Equipment) {
        if let index = profile.equipment.firstIndex(where: { $0.id == equipment.id }) {
            profile.equipment[index] = equipment
        } else {
            profile.equipment.append(equipment)
        }
    }

    func removeEquipment(atOffsets indexSet: IndexSet) {
        profile.equipment.remove(atOffsets: indexSet)
    }

    func logCheck(for equipment: Equipment, date: Date) {
        if let index = profile.equipment.firstIndex(where: { $0.id == equipment.id }) {
            profile.equipment[index].checkLog.append(Check(date: date))
        }
    }

    func removeChecks(for equipment: Equipment, atOffsets indexSet: IndexSet) {
        if let index = profile.equipment.firstIndex(where: { $0.id == equipment.id }) {
            profile.equipment[index].checkLog.remove(atOffsets: indexSet)
        }
    }
}
