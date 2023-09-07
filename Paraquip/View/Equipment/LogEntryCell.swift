//
//  LogEntryCell.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import CoreData

fileprivate let cellPadding = EdgeInsets(top: 8, leading: 40, bottom: 8, trailing: 0)

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
            LogEntryCellBackground(color: urgency.color,
                                   position: .start,
                                   icon: nil)
        )
        #if os(visionOS)
        .foregroundStyle(.primary)
        #endif
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
        #if os(visionOS)
        .foregroundStyle(.primary)
        #endif
        .quickLookPreview($previewedLogAttachment, in: logEntry.attachmentURLs)
        .listRowBackground(
            LogEntryCellBackground(color: nil,
                                   position: logEntry.isPurchase ? .end : .middle,
                                   icon: icon)
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


fileprivate struct LogEntryCellBackground: View {

    enum Position {
        case start, middle, end
    }

    let color: Color?
    let position: Position
    let icon: String?

    private let center = 32.0
    private let lineWidth = 3.0
    private var leadingLinePadding: Double {
        center - lineWidth / 2
    }
    private var circleDiameter: CGFloat {
        icon != nil ? 28 : 12
    }

    private var foregroundStyle: some ShapeStyle {
        if let color {
            return AnyShapeStyle(color)
        } else {
            #if os(visionOS)
            return AnyShapeStyle(.regularMaterial)
            #else
            return AnyShapeStyle(Color(uiColor: .tertiarySystemFill))
            #endif
        }
    }

    @ViewBuilder
    private func lineView(metrics: GeometryProxy) -> some View {
        Rectangle()
            .frame(
                width: lineWidth,
                height: (metrics.size.height - circleDiameter) / 2)
            .foregroundStyle(foregroundStyle)
    }

    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .topLeading) {
                if [.end, .middle].contains(position) {
                    lineView(metrics: metrics)
                        .padding(.leading, leadingLinePadding)
                }

                ZStack {
                    Circle()
                        .frame(width: circleDiameter, height: circleDiameter)
                        .foregroundStyle(foregroundStyle)
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 11, weight: .bold))
                    }
                }
                .padding(EdgeInsets(top: metrics.size.height / 2 - (circleDiameter / 2),
                                    leading: center - (circleDiameter / 2.0),
                                    bottom: 0,
                                    trailing: 0))

                if [.start, .middle].contains(position) {
                    lineView(metrics: metrics)
                        .padding(EdgeInsets(top: (metrics.size.height + circleDiameter) / 2,
                                            leading: leadingLinePadding,
                                            bottom: 0,
                                            trailing: 0))
                }
            }

        }
        #if os(visionOS)
        .background(.regularMaterial)
        #else
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        #endif
    }
}

struct TimelineView_Previews: PreviewProvider {

    private static func fakeEntry(isPurchase: Bool, hasAttachment: Bool = false) -> LogEntry {
        let logEntry = LogEntry.create(context: .preview)
        if isPurchase {
            CoreData.fakeProfile.allEquipment.first?.purchaseLog = logEntry
        }
        if hasAttachment {
            logEntry.addToAttachments(Attachment(context: .preview))
        }
        return logEntry
    }

    static var previews: some View {
        Group {
            List {
                NextCheckCell(urgency: .now, onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: false), onEdit: {}, onDelete: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: false, hasAttachment: true), onEdit: {}, onDelete: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: true), onEdit: {}, onDelete: {})
            }
            .listStyle(.insetGrouped)
            #if os(visionOS)
            .glassBackgroundEffect()
            #endif
        }

        Group {
            List {
                NextCheckCell(urgency: .soon(Date()), onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: true, hasAttachment: true), onEdit: {}, onDelete: {})
            }
            .listStyle(.insetGrouped)
        }

        Group {
            List {
                NextCheckCell(urgency: .later(Date()), onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: false), onEdit: {}, onDelete: {})
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
