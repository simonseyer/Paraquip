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

    func removeParaglider(atOffsets indexSet: IndexSet) {
        profile.paragliders.remove(atOffsets: indexSet)
    }

    func logCheck(for paraglider: Paraglider, date: Date) {
        guard let index = profile.paragliders.firstIndex(of: paraglider) else {
            return
        }

        profile.paragliders[index].checkLog.append(Check(date: date))
    }

    func removeChecks(for paraglider: Paraglider, atOffsets indexSet: IndexSet) {
        guard let index = profile.paragliders.firstIndex(of: paraglider) else {
            return
        }

        profile.paragliders[index].checkLog.remove(atOffsets: indexSet)
    }

    func store(paraglider: Paraglider) {
        if let index = profile.paragliders.firstIndex(of: paraglider) {
            profile.paragliders[index] = paraglider
        } else {
            profile.paragliders.append(paraglider)
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

extension Collection where Element: Identifiable {
    func firstIndex(of element: Element) -> Self.Index? {
        return firstIndex { (otherElement) -> Bool in
            element.id == otherElement.id
        }
    }
}
