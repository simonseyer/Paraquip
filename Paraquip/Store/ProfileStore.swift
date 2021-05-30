//
//  ProfileStore.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

class ProfileStore: ObservableObject {

    @Published private(set) var profile: Profile {
        didSet {
            save()
        }
    }

    private let persistence: ProfilePersistence

    init(profile: Profile, persistence: ProfilePersistence = .init()) {
        self.profile = profile.sorted()
        self.persistence = persistence
        save()
    }

    init?(id: UUID, persistence: ProfilePersistence = .init()) {
        guard let profile = persistence.load(with: id)?.toModel() else {
            return nil
        }
        self.profile = profile.sorted()
        self.persistence = persistence
    }

    private func save() {
        persistence.save(profile: profile.toPersistence())
    }

    func update(name: String) {
        profile.name = name
    }

    func equipment(with id: UUID) -> Equipment? {
        return profile.equipment.first { $0.id == id }
    }

    func store(equipment: Equipment) {
        var profile = self.profile
        if let index = profile.equipment.firstIndex(where: { $0.id == equipment.id }) {
            profile.equipment[index] = equipment
        } else {
            profile.equipment.append(equipment)
        }
        self.profile = profile.sorted()
    }

    func removeEquipment(atOffsets indexSet: IndexSet) {
        profile.equipment.remove(atOffsets: indexSet)
    }

    func logCheck(for equipment: Equipment, date: Date) {
        if let index = profile.equipment.firstIndex(where: { $0.id == equipment.id }) {
            var profile = self.profile
            profile.equipment[index].checkLog.append(Check(date: date))
            // TODO: optimise sorting
            profile.equipment[index].checkLog.sort { check1, check2 in
                return check1.date > check2.date
            }
            self.profile = profile.sorted()
        }
    }

    func removeChecks(for equipment: Equipment, atOffsets indexSet: IndexSet) {
        if let index = profile.equipment.firstIndex(where: { $0.id == equipment.id }) {
            var profile = self.profile
            profile.equipment[index].checkLog.remove(atOffsets: indexSet)
            self.profile = profile.sorted()
        }
    }
}

extension Profile {
    func sorted() -> Profile {
        // TODO: optimise sorting
        var profile = self
        profile.equipment.sort { equipment1, equipment2 in
            return equipment1.nextCheck < equipment2.nextCheck
        }
        return profile
    }
}
