//
//  Check.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.05.22.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

extension LogEntry {
    var logEntryDate: Date {
        get { date ?? Date.paraquipNow }
        set { date = newValue }
    }

    var logEntryAttachments: [LogAttachment] {
        (attachments?.allObjects as? [LogAttachment]) ?? []
    }

    var isTemporary: Bool {
        objectID.isTemporaryID
    }

    var isPurchase: Bool {
        equipmentPurchase != nil
    }

    static func create(context: NSManagedObjectContext, date: Date = .paraquipNow) -> Self {
        let logEntry = Self(context: context)
        logEntry.id = UUID()
        logEntry.date = date
        return logEntry
    }
}

extension LogAttachment {
    var attachmentContentType: UTType {
        get {
            guard let contentType = contentType else {
                return .data
            }
            return UTType(contentType) ?? UTType.data
        }
        set {
            contentType = newValue.identifier
        }
    }
}
