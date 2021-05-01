//
//  ProfileStore.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

class ProfileStore: ObservableObject {

    @Published var profile: Profile {
        didSet {
            persistence.save(profile: profile.toPersistence())
        }
    }

    private let persistence: ProfilePersistence

    init(profile: Profile, persistence: ProfilePersistence = .init()) {
        self.profile = persistence.load(with: profile.id)?.toModel() ?? profile
        self.persistence = persistence
    }

    func update(name: String) {
        profile.name = name
    }

    func equipment(with id: UUID) -> Equipment? {
        return profile.equipment.first { $0.id == id }
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
