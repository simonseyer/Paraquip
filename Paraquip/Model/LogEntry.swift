//
//  Check.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.05.22.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

extension LogEntry: Creatable {
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

    static func create(context: NSManagedObjectContext) -> Self {
        Self.create(context: context, date: .paraquipNow)
    }
}

extension URL {
    var contentType: UTType? {
        try? resourceValues(forKeys: [.contentTypeKey]).contentType
    }
}

extension LogAttachment {
    var attachmentContentType: UTType {
        guard let contentType = fileURL?.contentType else {
            return .data
        }
        return contentType
    }

    public override func willSave() {
        if isDeleted, let fileURL = fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        } else if let targetFileURL = targetFileURL, let fileURL = fileURL {
            try? FileManager.default.moveItem(at: fileURL, to: targetFileURL)
            self.fileURL = targetFileURL
            self.targetFileURL = nil
        }
    }
}
