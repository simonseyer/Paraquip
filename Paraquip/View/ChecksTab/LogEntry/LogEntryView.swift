//
//  LogEntryView.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import QuickLook

private extension Attachment {
    var name: String {
        fileURL?.lastPathComponent ?? ""
    }

    var icon: String {
        if contentType.conforms(to: .image) {
            return "photo"
        } else {
            return "doc"
        }
    }
}

struct LogEntryView: View {

    @ObservedObject var logEntry: LogEntry
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingDatePicker = false
    @State private var showingAddAttachment = false
    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @State private var showingDeleteCheck = false
    @State private var previewURL: URL?
    @State private var editMode: EditMode = .inactive

    @FetchRequest
    private var attachments: FetchedResults<Attachment>

    init(logEntry: LogEntry) {
        self.logEntry = logEntry
        _attachments = FetchRequest<Attachment>(sortDescriptors: [SortDescriptor(\.timestamp)],
                                                   predicate: NSPredicate(format: "%K == %@", #keyPath(Attachment.logEntry), logEntry))
        _showingDatePicker = .init(initialValue: logEntry.isInserted)
    }

    var body: some View {
        Form {
            Button {
                withAnimation {
                    showingDatePicker.toggle()
                }
            } label: {
                LabeledContent("Date") {
                    Text(logEntry.logEntryDate, style: .date)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)

            if showingDatePicker {
                DatePicker("", selection: $logEntry.logEntryDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }

            Section {
                ForEach(attachments) { attachment in
                    Button {
                        previewURL = attachment.fileURL
                    } label: {
                        Label(attachment.name,
                              systemImage: attachment.icon)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        managedObjectContext.delete(attachments[index])
                    }
                }
                Button {
                    withAnimation {
                        showingAddAttachment = true
                        editMode = .inactive
                    }
                } label: {
                    Label("Add attachment",
                          systemImage: "plus.circle")
                }
                .foregroundStyle(.accent)
                .confirmationDialog("Add attachment", isPresented: $showingAddAttachment) {
                    Button(action: { showingDocumentPicker = true }) {
                        Label("Document", systemImage: "doc")
                    }
                    Button(action: { showingImagePicker = true }) {
                        Label("Image", systemImage: "photo")
                    }
                }
            } header: {
                HStack {
                    Text("Attachments")
                    Button(editMode.title) {
                        withAnimation {
                            editMode.toggle()
                        }
                    }
                    .controlSize(.mini)
                    .disabled(attachments.isEmpty)
                }
            }

            if !logEntry.isInserted {
                Section {
                    Button(role: .destructive) {
                        showingDeleteCheck = true
                    } label: {
                        Label("Delete entry",
                              systemImage: "trash")
                        .foregroundStyle(.red)
                    }
                    .confirmationDialog("Delete entry", isPresented: $showingDeleteCheck) {
                        Button(role: .destructive) {
                            withAnimation {
                                managedObjectContext.delete(logEntry)
                                try! managedObjectContext.save()
                                dismiss()
                            }
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
        }
        .navigationTitle(logEntry.isPurchase ? "Purchase" : "Check")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    try! managedObjectContext.save()
                    dismiss()
                }
            }
        }
        .environment(\.editMode, $editMode)
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
            withAnimation {
                logEntry.addToAttachments(attachment)
            }
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
        NavigationStack {
            LogEntryView(logEntry: logEntry1)
                .environment(\.managedObjectContext, .preview)
        }
        NavigationStack {
            LogEntryView(logEntry: logEntry2)
                .environment(\.managedObjectContext, .preview)
        }
    }
}
