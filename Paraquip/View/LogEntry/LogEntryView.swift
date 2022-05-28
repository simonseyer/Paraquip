//
//  LogEntryView.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import UniformTypeIdentifiers

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
    @State private var previewedPDFAttachment: LogAttachment?

    var body: some View {
        Form {
            DatePicker("", selection: $logEntry.logEntryDate, displayedComponents: .date)
                .datePickerStyle(.graphical)

            Section("Attachments") {
                ForEach(logEntry.logEntryAttachments) { attachment in
                    if attachment.attachmentContentType == .pdf {
                        PDFAttachmentCell(attachment: attachment) {
                            previewedPDFAttachment = attachment
                        }
                    } else if attachment.attachmentContentType.supertypes.contains(.image) {
                        ImageAttachmentCell(attachment: attachment) {

                        }
                    }

                }

                Button(action: { showingDocumentPicker = true }) {
                    HStack {
                        Image(systemName: "doc.fill")
                            .font(.title)
                            .frame(width: 40)
                        Text("Attach file")
                    }
                }
                Button(action: { showingImagePicker = true }) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .font(.title)
                            .frame(width: 40)
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
        .sheet(item: $previewedPDFAttachment) { attachment in
            NavigationView {
                PDFAttachmentView(pdfData: attachment.data!, delete: {
                    managedObjectContext.delete(attachment)
                })
            }
        }
    }

    private func addAttachment(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let attachment = LogAttachment(context: managedObjectContext)
            attachment.fileName = url.lastPathComponent
            attachment.attachmentContentType = url.contentType ?? .data
            attachment.data = data
            logEntry.addToAttachments(attachment)
        } catch {
            // TODO: error handling
            print(error)
        }
    }
}

extension URL {
    var contentType: UTType? {
        try? resourceValues(forKeys: [.contentTypeKey]).contentType
    }
}

struct PDFAttachmentView: View {

    let pdfData: Data

    @Environment(\.dismiss) private var dismiss
    var delete: () -> Void

    var body: some View {
        PDFViewer(pdfData: pdfData)
            .navigationTitle("Attachment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") {
                        delete()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
}

struct LogEntryView_Previews: PreviewProvider {

    private static var logEntry: LogEntry {
        let logEntry = LogEntry.create(context: CoreData.previewContext)

        let attachment = LogAttachment(context: CoreData.previewContext)
        attachment.data = Data()
        attachment.fileName = "Rechnung Explorer.pdf"
        logEntry.addToAttachments(attachment)

        let attachment2 = LogAttachment(context: CoreData.previewContext)
        attachment2.data = Data()
        attachment2.fileName = "Bla bla Blaf.pdf"
        logEntry.addToAttachments(attachment2)

        return logEntry
    }

    static var previews: some View {
        NavigationView {
            LogEntryView(logEntry: logEntry, mode: .edit)
        }
        NavigationView {
            LogEntryView(logEntry: logEntry, mode: .create)
        }
    }
}

struct PDFAttachmentCell: View {

    let attachment: LogAttachment
    let previewAction: () -> Void

    var body: some View {
        Button(action: previewAction) {
            HStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .frame(width: 80, height: 80)
                    Image(systemName: "doc.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                .padding([.top, .bottom, .trailing], 8)

                if let name = attachment.fileName {
                    Text(name)
                }
            }
        }
        .foregroundColor(.black)
    }
}

struct ImageAttachmentCell: View {

    let attachment: LogAttachment
    let previewAction: () -> Void

    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .frame(width: 80, height: 80)
                Image(uiImage: UIImage(data: attachment.data!)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 76, height: 76)
                    .cornerRadius(10)
                    .clipped()

            }
            .padding([.top, .bottom, .trailing], 8)

            if let name = attachment.fileName {
                Text(name)
            }
        }
    }
}
