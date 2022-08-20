//
//  LogEntryView.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
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
    private var attachments: FetchedResults<Attachment>

    init(logEntry: LogEntry, mode: Mode) {
        self.logEntry = logEntry
        self.mode = mode
        _attachments = FetchRequest<Attachment>(sortDescriptors: [SortDescriptor(\.timestamp)],
                                                   predicate: NSPredicate(format: "%K == %@", #keyPath(Attachment.logEntry), logEntry))
    }

    var body: some View {
        Form {
            DatePicker("", selection: $logEntry.logEntryDate, displayedComponents: .date)
                .datePickerStyle(.graphical)

            if !attachments.isEmpty {
                Section("Attachments") {
                    ForEach(attachments) { attachment in
                        Button(action: { previewURL = attachment.fileURL }) {
                            HStack {
                                Group {
                                    if attachment.contentType.conforms(to: .pdf) {
                                        Image(systemName: "doc.fill")
                                    } else if attachment.contentType.conforms(to: .image) {
                                        Image(systemName: "photo.fill")
                                    }
                                }
                                .foregroundColor(Color(UIColor.darkGray))
                                .frame(width: 30)
                                Text(attachment.fileURL?.lastPathComponent ?? "")
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            managedObjectContext.delete(attachments[index])
                        }
                    }
                }
            }
            Section {
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
            DocumentPicker(contentTypes: [.pdf, .image], selectFile: addAttachment)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectFile: addAttachment)
        }
    }

    private func addAttachment(url: URL) {
        if let attachment = Attachment.create(fileURL: url, context: managedObjectContext) {
            logEntry.addToAttachments(attachment)
        }
    }
}

struct LogEntryView_Previews: PreviewProvider {

    private static var logEntry1: LogEntry {
        CoreData.fakeProfile.allEquipment.first { equipment in
            equipment.name == "Explorer 2"
        }!.allChecks.first!
    }
    private static var logEntry2: LogEntry {
        CoreData.fakeProfile.allEquipment.first { equipment in
            equipment.name == "Angel SQ"
        }!.allChecks.first!
    }

    static var previews: some View {
        NavigationView {
            LogEntryView(logEntry: logEntry1, mode: .edit)
                .environment(\.managedObjectContext, CoreData.previewContext)
        }
        NavigationView {
            LogEntryView(logEntry: logEntry2, mode: .create)
                .environment(\.managedObjectContext, CoreData.previewContext)
        }
    }
}
