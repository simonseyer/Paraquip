//
//  LogAttachment.swift
//  Paraquip
//
//  Created by Simon Seyer on 28.05.22.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

extension LogAttachment {

    var contentType: UTType {
        guard let contentType = try? fileURL?.resourceValues(forKeys: [.contentTypeKey]).contentType else {
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

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let attachmentsDirectory = documentsDirectory.appendingPathComponent("attachments")

        return attachmentsDirectory.appendingPathComponent(filePath)
    }

    static func create(fileURL: URL, context: NSManagedObjectContext) -> Self? {
        do {
            let fileManager = FileManager.default

            let filePath = URL(string: UUID().uuidString)!
                .appendingPathComponent(fileURL.lastPathComponent)
                .relativeString
                .removingPercentEncoding!

            let tempFileURL = fileManager.temporaryDirectory
                .appendingPathComponent(filePath)

            try fileManager.createDirectory(at: tempFileURL.deletingLastPathComponent(),
                                            withIntermediateDirectories: true)
            try fileManager.moveItem(at: fileURL, to: tempFileURL)

            let attachment = Self(context: context)
            attachment.filePath = filePath
            attachment.isTemporary = true
            attachment.timestamp = Date.paraquipNow
            return attachment
        } catch {
            print(error)
            return nil
        }
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
