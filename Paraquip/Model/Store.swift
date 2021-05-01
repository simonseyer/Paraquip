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
        if let paraglider = equipment as? Paraglider {
            profile.paragliders.updateOrInsert(paraglider)
        } else if let reserve = equipment as? Reserve {
            profile.reserves.updateOrInsert(reserve)
        }
    }

    func removeEquipment(atOffsets indexSet: IndexSet) {
        for equipmentIndex in indexSet {
            let equipment = profile.equipment[equipmentIndex]

            switch equipment {
            case is Paraglider:
                if let index = profile.paragliders.firstIndex(where: { $0.id == equipment.id }) {
                    profile.paragliders.remove(at: index)
                }
            case is Reserve:
                if let index = profile.reserves.firstIndex(where: { $0.id == equipment.id }) {
                    profile.reserves.remove(at: index)
                }
            default:
                break
            }
        }
    }

    func logCheck(for equipment: Equipment, date: Date) {
        switch equipment {
        case is Paraglider:
            if let index = profile.paragliders.firstIndex(where: { $0.id == equipment.id }) {
                profile.paragliders[index].checkLog.append(Check(date: date))
            }
        case is Reserve:
            if let index = profile.reserves.firstIndex(where: { $0.id == equipment.id }) {
                profile.reserves[index].checkLog.append(Check(date: date))
            }
        default:
            break
        }
    }

    func removeChecks(for equipment: Equipment, atOffsets indexSet: IndexSet) {
        switch equipment {
        case is Paraglider:
            if let index = profile.paragliders.firstIndex(where: { $0.id == equipment.id }) {
                profile.paragliders[index].checkLog.remove(atOffsets: indexSet)
            }
        case is Reserve:
            if let index = profile.reserves.firstIndex(where: { $0.id == equipment.id }) {
                profile.reserves[index].checkLog.remove(atOffsets: indexSet)
            }
        default:
            break
        }
    }
}

//protocol Store {
//    var profiles: AnyPublisher<[ProfileIdentifier], Never> { get }
//
//    func createProfile(name: String) -> ProfileStore
//    func delete(profile: ProfileIdentifier)
//    func store(for profileIdentifier: ProfileIdentifier) -> ProfileStore?
//}
//
//protocol ProfileStore {
//
//    var profile: AnyPublisher<Profile, Never> { get }
//
//    func update(name: String)
//
//    func add(paraglider: Paraglider)
//    func update(paraglider: Paraglider)
//}
//
//class InMemoryStore: Store {
//
//    private var storedProfiles: [ProfileIdentifier: ProfileStore] = [:] {
//        didSet {
//            profilesSubject.send(Array(storedProfiles.keys))
//        }
//    }
//    private var profilesSubject = CurrentValueSubject<[ProfileIdentifier], Never>([])
//
//    var profiles: AnyPublisher<[ProfileIdentifier], Never> {
//        profilesSubject.eraseToAnyPublisher()
//    }
//
//    func createProfile(name: String) -> ProfileStore {
//        let newProfile = Profile(name: name)
//        let store = InMemoryProfileStore(profile: newProfile)
//        storedProfiles[ProfileIdentifier(profile: newProfile)] = store
//        return store
//    }
//
//    func delete(profile: ProfileIdentifier) {
//        storedProfiles[profile] = nil
//    }
//
//    func store(for profileIdentifier: ProfileIdentifier) -> ProfileStore? {
//        return storedProfiles[profileIdentifier]
//    }
//}
//
//class InMemoryProfileStore: ProfileStore {
//
//    private var storedProfile: Profile {
//        didSet {
//            profileSubject.send(storedProfile)
//        }
//    }
//    private var profileSubject = PassthroughSubject<Profile, Never>()
//
//    var profile: AnyPublisher<Profile, Never> {
//        profileSubject.eraseToAnyPublisher()
//    }
//
//    init(profile: Profile) {
//        self.storedProfile = profile
//    }
//
//    func update(name: String) {
//        storedProfile.name = name
//    }
//
//    func add(paraglider: Paraglider) {
//        storedProfile.paragliders.append(paraglider)
//    }
//
//    func update(paraglider: Paraglider) {
//        guard let index = storedProfile.paragliders.firstIndex(of: paraglider) else {
//            return
//        }
//        storedProfile.paragliders[index] = paraglider
//    }
//}

extension Array where Element: Identifiable {
    func firstIndex(of element: Element) -> Self.Index? {
        return firstIndex { (otherElement) -> Bool in
            element.id == otherElement.id
        }
    }

    mutating func updateOrInsert(_ element: Element) {
        if let index = self.firstIndex(of: element) {
            self[index] = element
        } else {
            self.append(element)
        }
    }
}
