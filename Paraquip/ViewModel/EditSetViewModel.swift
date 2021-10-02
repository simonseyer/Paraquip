//
//  EditSetView.swift
//  EditSetView
//
//  Created by Simon Seyer on 28.08.21.
//

import Foundation

class EditSetViewModel: ObservableObject {

    @Published var profile: Profile.Description
    @Published private(set) var equipment: [Equipment] = []
    @Published private(set) var selectedEquipment: Set<UUID> = []

    private let appStore: AppStore

    init(appStore: AppStore, profile: Profile.Description) {
        self.appStore = appStore
        self.profile = profile
        equipment = appStore.allEquipment()

        let profileEquipment = appStore.store(for: profile)?.profile.value.equipment ?? []
        selectedEquipment = Set<UUID>(profileEquipment.map { $0.id })
    }

    func toggle(equipment: Equipment) {
        if selectedEquipment.contains(equipment.id) {
            selectedEquipment.remove(equipment.id)
        } else {
            selectedEquipment.insert(equipment.id)
        }
    }

    func isSelected(equipment: Equipment) -> Bool {
        return selectedEquipment.contains(equipment.id)
    }

    func save() {
        appStore.store(profile: profile)

        let newEquipment = equipment.filter { selectedEquipment.contains($0.id) }
        appStore.store(for: profile)?.updateContainedEquipment(newEquipment)
    }
}
