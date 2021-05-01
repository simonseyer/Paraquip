//
//  ProfilePersistence.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

class ProfilePersistence {

    private let basePath: URL
    private let fileManager: FileManager

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.basePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func save(profile: PersistedProfile) {
        do {
            let url = basePath.appendingPathComponent(profile.id.uuidString)
            let data = try encoder.encode(profile)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to write profile: \(error)")
        }
    }

    func load(with id: UUID) -> PersistedProfile? {
        let url = basePath.appendingPathComponent(id.uuidString)
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(PersistedProfile.self, from: data)
        } catch {
            print("Failed to load profile: \(error)")
            return nil
        }
    }
}
