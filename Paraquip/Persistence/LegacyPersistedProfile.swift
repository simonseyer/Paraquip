//
//  PersistedProfile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct PersistedProfile: Codable {
    var id: UUID
    var name: String
    var paraglider: [PersistedParaglider]
    var reserves: [PersistedReserve]
    var harnesses: [PersistedHarness]
}

struct PersistedParaglider: Codable {
    var id: UUID
    var brand: String
    var brandId: String?
    var name: String
    var size: String
    var checkCycle: Int
    var checkLog: [PersistedCheck]
    var purchaseDate: Date?
}

struct PersistedReserve: Codable {
    var id: UUID
    var brand: String
    var brandId: String?
    var name: String
    var checkCycle: Int
    var checkLog: [PersistedCheck]
    var purchaseDate: Date?
}

struct PersistedHarness: Codable {
    var id: UUID
    var brand: String
    var brandId: String?
    var name: String
    var checkCycle: Int
    var checkLog: [PersistedCheck]
    var purchaseDate: Date?
}

struct PersistedCheck: Codable {
    var id = UUID()
    var date: Date
}
