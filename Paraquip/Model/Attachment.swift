//
//  Attachment.swift
//  Paraquip
//
//  Created by Simon Seyer on 28.05.22.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

extension Attachment {

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
        guard let filePath else { return nil }

        return FileManager.default.temporaryDirectory.appendingPathComponent(filePath)
    }

    private var documentsFileURL: URL? {
        guard let filePath else { return nil }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let attachmentsDirectory = documentsDirectory.appendingPathComponent("attachments")

        return attachmentsDirectory.appendingPathComponent(filePath)
    }

    static func create(fileURL: URL, context: NSManagedObjectContext) -> Self? {
        let fileManager = FileManager.default
        let filePath = filePath(for: fileURL.lastPathComponent)
        let tempFileURL = fileManager.temporaryDirectory.appendingPathComponent(filePath)

        do {
            try fileManager.createDirectory(at: tempFileURL.deletingLastPathComponent(),
                                            withIntermediateDirectories: true)
            try fileManager.moveItem(at: fileURL, to: tempFileURL)
            return create(filePath: filePath, context: context)
        } catch {
            print(error)
            return nil
        }
    }

    static func create(data: Data, fileName: String, context: NSManagedObjectContext) -> Self? {
        let fileManager = FileManager.default
        let filePath = filePath(for: fileName)
        let tempFileURL = fileManager.temporaryDirectory.appendingPathComponent(filePath)

        do {
            try fileManager.createDirectory(at: tempFileURL.deletingLastPathComponent(),
                                            withIntermediateDirectories: true)
            try data.write(to: tempFileURL)
            return create(filePath: filePath, context: context)
        } catch {
            print(error)
            return nil
        }
    }

    private static func filePath(for fileName: String) -> String {
        URL(string: UUID().uuidString)!
            .appendingPathComponent(fileName)
            .relativeString
            .removingPercentEncoding!
    }

    private static func create(filePath: String, context: NSManagedObjectContext) -> Self {
        let attachment = Self(context: context)
        attachment.filePath = filePath
        attachment.isTemporary = true
        attachment.timestamp = Date.now
        return attachment
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
