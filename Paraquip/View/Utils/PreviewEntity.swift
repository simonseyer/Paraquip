//
//  PreviewEntity.swift
//  Paraquip
//
//  Created by Simon Seyer on 31.08.23.
//

import Foundation
import CoreData

@MainActor
extension Equipment {
    static var previewEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: .preview)!
    }
}
