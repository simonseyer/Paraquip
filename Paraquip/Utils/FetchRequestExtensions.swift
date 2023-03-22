//
//  FetchRequestExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.03.23.
//

import Foundation
import CoreData
import SwiftUI

fileprivate extension ProcessInfo {
    static var isPreview: Bool {
        return processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

fileprivate struct SortDescriptorConverter: Codable {
    private let order: Bool
    private let keyString: String

    static func nsSortDescriptors<T: NSManagedObject>(for sortDescriptors: [SortDescriptor<T>]) -> [NSSortDescriptor] {
        let encodedSortDescriptors = try! JSONEncoder().encode(sortDescriptors)
        let decodedSortDescriptors = try! JSONDecoder().decode([Self].self, from: encodedSortDescriptors)
        return decodedSortDescriptors.map {
            NSSortDescriptor(key: $0.keyString, ascending: $0.order)
        }
    }
}

extension FetchRequest where Result : NSManagedObject {
    init(previewEntity: @autoclosure () -> NSEntityDescription,
         sortDescriptors: [SortDescriptor<Result>],
         predicate: NSPredicate? = nil) {
        if ProcessInfo.isPreview {
            let nssSortDescriptors = SortDescriptorConverter.nsSortDescriptors(for: sortDescriptors)
            self.init(entity: previewEntity(),
                      sortDescriptors: nssSortDescriptors,
                      predicate: predicate)
        } else {
            self.init(sortDescriptors: sortDescriptors,
                      predicate: predicate)
        }
    }
}

extension SectionedFetchRequest where Result : NSManagedObject {
    init(previewEntity: @autoclosure () -> NSEntityDescription,
         sectionIdentifier: KeyPath<Result, SectionIdentifier>,
         sortDescriptors: [SortDescriptor<Result>],
         predicate: NSPredicate? = nil) {
        if ProcessInfo.isPreview {
            let nssSortDescriptors = SortDescriptorConverter.nsSortDescriptors(for: sortDescriptors)
            self.init(entity: previewEntity(),
                      sectionIdentifier: sectionIdentifier,
                      sortDescriptors: nssSortDescriptors,
                      predicate: predicate)
        } else {
            self.init(sectionIdentifier: sectionIdentifier,
                      sortDescriptors: sortDescriptors,
                      predicate: predicate)
        }
    }
}
