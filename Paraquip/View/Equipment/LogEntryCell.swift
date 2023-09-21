//
//  LogEntryCell.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import CoreData

fileprivate let cellPadding = EdgeInsets(top: 10, leading: 56, bottom: 10, trailing: 0)

struct NextCheckCell: View {

    let urgency: Equipment.CheckUrgency
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(urgency.formattedCheckInterval)
            Spacer()
            Button(action: onTap) {
                Image(systemName: "square.and.pencil")
            }
            .padding(.horizontal)
        }
        .padding(cellPadding)
        .listRowBackground(
            LogEntryBackground(color: urgency.color,
                               position: .start,
                               icon: nil)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

struct LogEntryCell: View {

    @ObservedObject var logEntry: LogEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var previewedLogAttachment: URL?
    @State private var deleteLogEntry: LogEntry?
    @State private var isDeletingLogEntry = false

    private var icon: String {
        logEntry.isPurchase ? "dollarsign" : "checkmark"
    }

    var body: some View {
        HStack {
            Text(logEntry.logEntryDate, format: Date.FormatStyle(date: .long, time: .omitted))
                .padding(cellPadding)
            Spacer()
            if logEntry.attachments?.count ?? 0 > 0 {
                Button(action: {
                    previewedLogAttachment = logEntry.attachmentURLs.first
                }) {
                    Image(systemName: "paperclip")
                }
                .padding(.horizontal)
            }
        }
        .quickLookPreview($previewedLogAttachment, in: logEntry.attachmentURLs)
        .listRowBackground(
            LogEntryBackground(color: nil,
                               position: logEntry.isPurchase ? .end : .middle,
                               icon: icon)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .confirmationDialog(Text("Delete log entry"), isPresented: $isDeletingLogEntry, presenting: deleteLogEntry) { logEntry in
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                deleteLogEntry = logEntry
                isDeletingLogEntry = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct TimelineView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            List {
                NextCheckCell(urgency: .now, onTap: {})
                LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: false), onEdit: {}, onDelete: {})
                LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: false, hasAttachment: true), onEdit: {}, onDelete: {})
                LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: true), onEdit: {}, onDelete: {})
            }
            .listStyle(.insetGrouped)
        }

        Group {
            List {
                NextCheckCell(urgency: .soon(Date()), onTap: {})
                LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: true, hasAttachment: true), onEdit: {}, onDelete: {})
            }
            .listStyle(.insetGrouped)
        }

        Group {
            List {
                NextCheckCell(urgency: .later(Date()), onTap: {})
                LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: false), onEdit: {}, onDelete: {})
            }
            .listStyle(.insetGrouped)
        }

        Group {
            List {
                NextCheckCell(urgency: .never, onTap: {})
            }
            .listStyle(.insetGrouped)
        }
    }
}
