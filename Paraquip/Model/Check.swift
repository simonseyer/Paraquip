//
//  Check.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.05.22.
//

import Foundation
import CoreData

extension Check {
    var checkDate: Date {
        get { date ?? Date.paraquipNow }
        set { date = newValue }
    }

    var isTemporary: Bool {
        objectID.isTemporaryID
    }

    var isPurchase: Bool {
        equipmentPurchase != nil
    }

    static func create(context: NSManagedObjectContext, date: Date = .paraquipNow) -> Self {
        let check = Self(context: context)
        check.id = UUID()
        check.date = date
        return check
    }
}
