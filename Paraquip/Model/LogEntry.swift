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

    var logEntryAttachments: [Attachment] {
        (attachments?.allObjects as? [Attachment]) ?? []
    }

    var attachmentURLs: [URL] {
        logEntryAttachments.compactMap { $0.fileURL }
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

    static func create(context: NSManagedObjectContext) -> Self {
        Self.create(context: context, date: .paraquipNow)
    }
}
