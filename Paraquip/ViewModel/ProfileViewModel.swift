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

    func store(equipment: Equipment, lastCheckDate: Date?, manualURL: URL?) {
        profileStore.store(equipment: equipment)
        if let date = lastCheckDate {
            profileStore.logCheck(at: date, for: equipment)
        }
        if let url = manualURL {
            do {
                let data = try Data(contentsOf: url)
                profileStore.attach(manual: data, to: equipment)
            } catch {
                print(error)
            }
        }
    }

    func removeEquipment(atOffsets indexSet: IndexSet) {
        let equipment = indexSet.map { profile.equipment[$0] }
        profileStore.remove(equipment: equipment)
    }

    func viewModel(for equipment: Equipment) -> EquipmentViewModel {
        EquipmentViewModel(store: profileStore, equipment: equipment)
    }
}

extension ProfileViewModel {
    static func fake(profile: Profile = .fake()) -> ProfileViewModel {
        ProfileViewModel(store: FakeProfileStore(profile: profile))
    }
}
