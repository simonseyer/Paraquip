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

    var attachmentURLs: [URL] {
        logEntryAttachments.compactMap { $0.fileURL }
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

    var fileURL: URL? {
        isTemporary ? temporaryFileURL : documentsFileURL
    }

    private var temporaryFileURL: URL? {
        guard let filePath = filePath else {
            return nil
        }

        return FileManager.default.temporaryDirectory.appendingPathComponent(filePath)
    }

    private var documentsFileURL: URL? {
        guard let filePath = filePath else {
            return nil
        }

        return FileManager.default.attachmentsDirectory.appendingPathComponent(filePath)
    }

    public override func willSave() {
        if isDeleted, let fileURL = fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        } else if isTemporary, let temporaryFileURL = temporaryFileURL, let documentsFileURL = documentsFileURL {
            try? FileManager.default.createDirectory(at: documentsFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? FileManager.default.moveItem(at: temporaryFileURL, to: documentsFileURL)
            self.isTemporary = false
        }
    }
}

extension FileManager {
    var attachmentsDirectory: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("attachments")
    }
}
