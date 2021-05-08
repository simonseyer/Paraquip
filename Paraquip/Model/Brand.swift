//
//  Brand.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import Foundation

struct Brand {
    var name: String
    var id: String?
}

extension Brand {
    // Add harness brands
    static var allBrands: [Brand] = [
        Brand(name: "Advance", id: "advance"),
        Brand(name: "Air G", id: "air-g"),
        Brand(name: "Air Cross", id: "aircross"),
        Brand(name: "Airdesign", id: "airdesign"),
        Brand(name: "Axis", id: "axis"),
        Brand(name: "Dudek", id: "dudek"),
        Brand(name: "Gin", id: "gin"),
        Brand(name: "Icaro", id: "icaro"),
        Brand(name: "Independence", id: "independence"),
        Brand(name: "ITT", id: "itt"),
        Brand(name: "ITV", id: "itv"),
        Brand(name: "Mac Para", id: "macpara"),
        Brand(name: "Neo", id: "neo"),
        Brand(name: "Nervures", id: "nervures"),
        Brand(name: "Nirvana", id: "nirvana"),
        Brand(name: "Niviuk", id: "niviuk"),
        Brand(name: "Nova", id: "nova"),
        Brand(name: "NZ Aeropsports", id: "nz-aerosports"),
        Brand(name: "Olympus", id: "olympus"),
        Brand(name: "Ozone", id: "ozone"),
        Brand(name: "Pro design", id: "pro-design"),
        Brand(name: "Sky Country", id: "sky-country"),
        Brand(name: "Sky Paragliders", id: "sky-paragliders"),
        Brand(name: "Skyline", id: "skyline"),
        Brand(name: "Skywalk", id: "skywalk"),
        Brand(name: "SOL Paragliders", id: "sol"),
        Brand(name: "Supair", id: "supair"),
        Brand(name: "Swing", id: "swing"),
        Brand(name: "Trekking Parapentes", id: "trekking-parapentes"),
        Brand(name: "Triple Seven Gliders", id: "triple-seven"),
        Brand(name: "U-Turn", id: "u-turn"),
        Brand(name: "Up", id: "up"),
        Brand(name: "Windtech", id: "windtech"),
    ]
}
