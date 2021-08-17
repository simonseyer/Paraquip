//
//  ProfileViewModel.swift
//  Paraquip
//
//  Created by Simon Seyer on 17.08.21.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {

    private let profileStore: ProfileStore
    private var subscriptions: Set<AnyCancellable> = []

    @Published private(set) var profile: Profile

    init(store: ProfileStore) {
        self.profileStore = store
        self.profile = store.profile.value

        store.profile
            .sink { self.profile = $0 }
            .store(in: &subscriptions)
    }

    func store(equipment: Equipment) {
        profileStore.store(equipment: equipment)
    }

    func removeEquipment(atOffsets indexSet: IndexSet) {
        let equipment = indexSet.map { profile.equipment[$0] }
        profileStore.remove(equipment: equipment)
    }

    func logCheck(for equipment: Equipment, date: Date) {
        profileStore.logCheck(at: date, for: equipment)
    }

    func removeChecks(for equipment: Equipment, atOffsets indexSet: IndexSet) {
        let checks = indexSet.map { equipment.checkLog[$0] }
        profileStore.remove(checks: checks, for: equipment)
    }
}

extension ProfileViewModel {
    func equipment(with id: UUID) -> Equipment? {
        return profile.equipment.first { $0.id == id }
    }
}

extension ProfileViewModel {
    static func fake(profile: Profile = .fake()) -> ProfileViewModel {
        ProfileViewModel(store: FakeProfileStore(profile: profile))
    }
}
