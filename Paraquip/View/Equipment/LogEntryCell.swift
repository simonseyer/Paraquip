//
//  LogEntryCell.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import CoreData

struct NextCheckCell: View {

    let urgency: Equipment.CheckUrgency
    let onTap: () -> Void

    @State private var isHighlighted = false

    var body: some View {
        HStack {
            Text(urgency.formattedCheckInterval)
            Spacer()
            Image(systemName: "square.and.pencil")
                .font(Font.body.weight(.medium))
                .foregroundColor(.accentColor)
        }
        .padding(LogEntryCellBackground.padding)

        .listRowBackground(
            LogEntryCellBackground(color: urgency.color,
                           position: .start,
                           isHighlighted: $isHighlighted)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged { _ in isHighlighted = true }
                .onEnded { _ in isHighlighted = false }
        )
    }
}

struct LogEntryCell: View {

    @ObservedObject var logEntry: LogEntry
    let onTap: () -> Void

    @State private var isHighlighted = false

    var body: some View {
        HStack {
            Text(logEntry.logEntryDate, format: Date.FormatStyle(date: .long, time: .omitted))
            Spacer()
            if logEntry.attachments?.count ?? 0 > 0 {
                Image(systemName: "paperclip")
                    .font(Font.body.weight(.medium))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(LogEntryCellBackground.padding)
        .listRowBackground(
            LogEntryCellBackground(color: Color(UIColor.systemGray3),
                           position: logEntry.isPurchase ? .end : .middle,
                           isHighlighted: $isHighlighted)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged { _ in isHighlighted = true }
                .onEnded { _ in isHighlighted = false }
        )
    }
}

fileprivate struct LogEntryCellBackground: View {

    enum Position {
        case start, middle, end
    }

    let color: Color
    let position: Position
    @Binding var isHighlighted: Bool

    static let padding = EdgeInsets(top: 13, leading: 36, bottom: 13, trailing: 0)

    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .topLeading) {
                if isHighlighted {
                    Color(UIColor.systemGray4)
                } else {
                    Color.white
                }
                Group {
                Rectangle()
                    .frame(
                        width: 2,
                        height: metrics.size.height * (position == .middle ? 1.0 : 0.5))
                    .foregroundColor(color)
                    .opacity(0.4)
                    .padding(EdgeInsets(top: metrics.size.height * (position == .start ? 0.5 : 0.0),
                                        leading: 4,
                                        bottom: 0,
                                        trailing: 0))
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(color)
                    .padding(.top, metrics.size.height / 2 - 5)
                }
                .padding(.leading, 27)
            }
        }
    }
}

struct TimelineView_Previews: PreviewProvider {

    private static func fakeEntry(isPurchase: Bool, hasAttachment: Bool = false) -> LogEntry {
        let logEntry = LogEntry.create(context: CoreData.previewContext)
        if isPurchase {
            CoreData.fakeProfile.allEquipment.first?.purchaseLog = logEntry
        }
        if hasAttachment {
            let attachment = LogAttachment(context: CoreData.previewContext)
            attachment.data = Data()
            attachment.fileName = "Rechnung Explorer.pdf"
            logEntry.addToAttachments(attachment)
        }
        return logEntry
    }

    static var previews: some View {
        Group {
            List {
                NextCheckCell(urgency: .now, onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: false), onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: false, hasAttachment: true), onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: true), onTap: {})
            }
            .listStyle(.insetGrouped)
        }

        Group {
            List {
                NextCheckCell(urgency: .soon(Date()), onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: true, hasAttachment: true), onTap: {})
            }
            .listStyle(.insetGrouped)
        }

        Group {
            List {
                NextCheckCell(urgency: .later(Date()), onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: false), onTap: {})
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
