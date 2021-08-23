//
//  Brand.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import Foundation

enum Brand {
    case none
    case known(name: String, id: String)
    case custom(name: String)

    var name: String {
        switch self {
        case .none:
            return ""
        case .custom(let name):
            return name
        case .known(let name, _):
            return name
        }
    }

    private static let noneId = "none"
    private static let customId = "custom"

    var id: String {
        switch self {
        case .none:
            return Self.noneId
        case .custom:
            return Self.customId
        case .known(_, let id):
            return id
        }
    }

    init(name: String, id: String?) {
        if let id = id, id != Self.customId {
            self = .known(name: name, id: id)
        } else if !name.isEmpty {
            self = .custom(name: name)
        } else {
            self = .none
        }
    }
}

extension Brand: CaseIterable {

    static var allCases: [Brand] = [
        Brand.custom(name: ""),
        Brand.known(name: "Advance", id: "advance"),
        Brand.known(name: "Air G", id: "air-g"),
        Brand.known(name: "Aeros", id: "aeros"),
        Brand.known(name: "Air Cross", id: "aircross"),
        Brand.known(name: "Airdesign", id: "airdesign"),
        Brand.known(name: "Axis", id: "axis"),
        Brand.known(name: "Basisrausch", id: "basisrausch"),
        Brand.known(name: "Charly", id: "charly"),
        Brand.known(name: "Dudek", id: "dudek"),
        Brand.known(name: "Fly Products", id: "fly-products"),
        Brand.known(name: "Gin", id: "gin"),
        Brand.known(name: "Icaro", id: "icaro"),
        Brand.known(name: "Independence", id: "independence"),
        Brand.known(name: "ITT", id: "itt"),
        Brand.known(name: "ITV", id: "itv"),
        Brand.known(name: "Mac Para", id: "macpara"),
        Brand.known(name: "Neo", id: "neo"),
        Brand.known(name: "Nervures", id: "nervures"),
        Brand.known(name: "Nirvana", id: "nirvana"),
        Brand.known(name: "Niviuk", id: "niviuk"),
        Brand.known(name: "Nova", id: "nova"),
        Brand.known(name: "NZ Aeropsports", id: "nz-aerosports"),
        Brand.known(name: "Olympus", id: "olympus"),
        Brand.known(name: "Ozone", id: "ozone"),
        Brand.known(name: "Pro design", id: "pro-design"),
        Brand.known(name: "Sky Country", id: "sky-country"),
        Brand.known(name: "Sky Paragliders", id: "sky-paragliders"),
        Brand.known(name: "Skyline", id: "skyline"),
        Brand.known(name: "Skywalk", id: "skywalk"),
        Brand.known(name: "SOL Paragliders", id: "sol"),
        Brand.known(name: "Squirrel", id: "squirrel"),
        Brand.known(name: "Supair", id: "supair"),
        Brand.known(name: "Swing", id: "swing"),
        Brand.known(name: "Trekking Parapentes", id: "trekking-parapentes"),
        Brand.known(name: "Triple Seven Gliders", id: "triple-seven"),
        Brand.known(name: "U-Turn", id: "u-turn"),
        Brand.known(name: "Up", id: "up"),
        Brand.known(name: "Windtech", id: "windtech"),
        Brand.known(name: "Woody Valley", id: "woody-valley"),
    ]
}
