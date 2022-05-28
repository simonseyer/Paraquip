//
//  LogEntryView.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import UniformTypeIdentifiers
import QuickLook

struct LogEntryView: View {
    enum Mode {
        case create, edit, inline
    }

    @ObservedObject var logEntry: LogEntry
    let mode: Mode

    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @State private var previewURL: URL?

    @FetchRequest
    private var attachments: FetchedResults<LogAttachment>

    init(logEntry: LogEntry, mode: Mode) {
        self.logEntry = logEntry
        self.mode = mode
        _attachments = FetchRequest<LogAttachment>(sortDescriptors: [SortDescriptor(\.timestamp)],
                                                   predicate: NSPredicate(format: "%K == %@", #keyPath(LogAttachment.logEntry), logEntry))
    }

    var body: some View {
        Form {
            DatePicker("", selection: $logEntry.logEntryDate, displayedComponents: .date)
                .datePickerStyle(.graphical)

            Section("Attachments") {
                ForEach(attachments) { attachment in
                    Button(action: { previewURL = attachment.fileURL }) {
                        HStack {
                            Group {
                                if attachment.attachmentContentType == .pdf {
                                    Image(systemName: "doc.fill")
                                } else if attachment.attachmentContentType.supertypes.contains(.image) {
                                    Image(systemName: "photo.fill")
                                }
                            }
                            .foregroundColor(Color(UIColor.darkGray))
                            .frame(width: 30)
                            Text(attachment.fileURL?.lastPathComponent ?? "")
                        }
                    }
                    .foregroundColor(.black)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        managedObjectContext.delete(attachments[index])
                    }
                }

                Button(action: { showingDocumentPicker = true }) {
                    HStack {
                        Image(systemName: "doc.fill")
                            .frame(width: 30)
                        Text("Attach file")
                    }
                }
                Button(action: { showingImagePicker = true }) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .frame(width: 30)
                        Text("Attach image")
                    }
                }
            }
        }
        .navigationTitle(logEntry.isPurchase ? "Purchase" : "Check")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if mode != .inline {
                    Button("Cancel") { dismiss() }
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                if mode == .edit {
                    Button("Delete") {
                        managedObjectContext.delete(logEntry)
                        try! managedObjectContext.save()
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                if mode != .inline {
                    Button(mode == .create ? "Log" : "Save") {
                        try! managedObjectContext.save()
                        dismiss()
                    }
                }
            }
        }
        .quickLookPreview($previewURL)
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(contentTypes: [.pdf, .image]) { url in
                addAttachment(url: url)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { url in
                addAttachment(url: url)
            }
        }
    }

    private func addAttachment(url: URL) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUUID = UUID().uuidString

            let tempURL = fileManager
                .temporaryDirectory
                .appendingPathComponent(fileUUID)
            try fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true)

            let documentsURL = documentsDirectory
                .appendingPathComponent("attachments")
                .appendingPathComponent(fileUUID)
            try fileManager.createDirectory(at: documentsURL, withIntermediateDirectories: true)

            let tempFileURL = tempURL.appendingPathComponent(url.lastPathComponent)
            let targetURL = documentsURL.appendingPathComponent(url.lastPathComponent)

            try fileManager.moveItem(at: url, to: tempFileURL)

            let attachment = LogAttachment(context: managedObjectContext)
            attachment.fileURL = tempFileURL
            attachment.targetFileURL = targetURL
            attachment.timestamp = Date.paraquipNow

            logEntry.addToAttachments(attachment)
        } catch {
            // TODO: error handling
            print(error)
        }
    }
}

struct LogEntryView_Previews: PreviewProvider {

    private static var logEntry: LogEntry {
        CoreData.fakeProfile.allEquipment.first { equipment in
            equipment.name == "Explorer 2"
        }!.allChecks.first!
    }

    static var previews: some View {
        NavigationView {
            LogEntryView(logEntry: logEntry, mode: .edit)
                .environment(\.managedObjectContext, CoreData.previewContext)
        }
        NavigationView {
            LogEntryView(logEntry: logEntry, mode: .create)
                .environment(\.managedObjectContext, CoreData.previewContext)
        }
    }
}
