//
//  SetViewModel.swift
//  SetViewModel
//
//  Created by Simon Seyer on 25.08.21.
//

import Foundation
import Combine

class SetViewModel: ObservableObject {
    private let appStore: AppStore
    private var subscriptions: Set<AnyCancellable> = []

    @Published private(set) var profiles: [Profile.Description]

    var primaryProfile: Profile.Description {
        Profile.Description(profile: appStore.mainProfileStore.profile.value)
    }

    init(store: AppStore) {
        self.appStore = store

        self.profiles = store.profiles.value
        store.profiles
            .sink { self.profiles = $0 }
            .store(in: &subscriptions)
    }

    func viewModel(for profile: Profile.Description) -> ProfileViewModel {
        ProfileViewModel(store: appStore.store(for: profile)!)
    }

    func editSetViewModel(for profile: Profile.Description) -> EditSetViewModel {
        EditSetViewModel(appStore: appStore, profile: profile)
    }

//    func equipmentViewModel(for equipment: Equipment) -> EquipmentViewModel {
//        EquipmentViewModel(store: profileStore, equipment: equipment)
//    }

    func delete(profile: Profile.Description) {
        appStore.remove(profile: profile)
    }
}
