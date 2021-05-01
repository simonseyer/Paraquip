//
//  Profile.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.05.21.
//

import Foundation

struct Profile: Identifiable {
    var id = UUID()
    var name: String
    var equipment: [Equipment] = []
}
