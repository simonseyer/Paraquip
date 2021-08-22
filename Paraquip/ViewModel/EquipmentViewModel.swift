//
//  EquipmentViewModel.swift
//  Paraquip
//
//  Created by Simon Seyer on 19.08.21.
//

import Foundation
import Combine

struct PlaceholderEquipment: Equipment {
    var id: UUID = .init()
    var brand: Brand = .none
    var name: String = ""
    var checkCycle: Int = 0
    var checkLog: [Check] = []
    var purchaseDate: Date? = nil
}

class EquipmentViewModel: ObservableObject {

    private let profileStore: ProfileStore
    private var subscriptions: Set<AnyCancellable> = []

    @Published private(set) var equipment: Equipment

    init(store: ProfileStore, equipment: Equipment) {
        self.profileStore = store
        self.equipment = equipment

        store.profile
            .map { $0.equipment(for: equipment.id) }
            .sink { self.equipment = $0 }
            .store(in: &subscriptions)
    }

    func logCheck(at date: Date) {
        profileStore.logCheck(at: date, for: equipment)
    }

    func removeChecks(atOffsets indexSet: IndexSet) {
        let checks = indexSet.map { equipment.checkLog[$0] }
        profileStore.remove(checks: checks, for: equipment)
    }

    func attachManual(at url: URL) {
        do {
            let data = try Data(contentsOf: url)
            profileStore.attach(manual: data, to: equipment)
        } catch {
            print(error)
        }
    }

    func loadManual() -> Data? {
        return profileStore.loadManual(for: equipment)
    }

    func deleteManual() {
        profileStore.deleteManual(for: equipment)
    }

    func editEquipmentViewModel() -> EditEquipmentViewModel {
        EditEquipmentViewModel(store: profileStore, equipment: equipment, isNew: false)
    }
}

fileprivate extension Profile {
    func equipment(for id: UUID) -> Equipment {
        equipment.first { $0.id == id } ?? PlaceholderEquipment()
    }
}
