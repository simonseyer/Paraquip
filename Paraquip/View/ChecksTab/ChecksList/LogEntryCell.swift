//
//  LogEntryCell.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import CoreData

private struct LogEntryCellButton<Content: View, Background: View>: View {

    let action: () -> Void
    let content: () -> Content
    let background: () -> Background

    @State private var isHighlighted = false

    private var backgroundColor: Color {
        if isHighlighted {
            Color(uiColor: .systemGray4)
        } else {
            Color(uiColor: .secondarySystemGroupedBackground)
        }
    }

    init(action: @escaping () -> Void,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder background: @escaping () -> Background) {
        self.action = action
        self.content = content
        self.background = background
    }

    var body: some View {
        Button(action: {  /* ignore */  }) {
            content()
        }
        .padding(EdgeInsets(top: 10, leading: 56,
                            bottom: 10, trailing: 0))
        .foregroundStyle(.primary)
        .listRowBackground(background().background(backgroundColor))
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded(action))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged { _ in isHighlighted = true }
                .onEnded { _ in isHighlighted = false }
        )
    }
}

struct NextCheckCell: View {

    let urgency: Equipment.CheckUrgency
    let onTap: () -> Void

    var body: some View {
        LogEntryCellButton(action: onTap) {
            HStack {
                Text(urgency.formattedCheckInterval)
                Spacer()
                Image(systemName: "square.and.pencil")
                    .padding(.horizontal)
            }
        } background: {
            LogEntryBackground(color: urgency.color,
                               position: .start,
                               icon: nil)
        }
    }
}

struct LogEntryCell: View {

    @ObservedObject var logEntry: LogEntry
    let onTap: () -> Void

    private var icon: String {
        logEntry.isPurchase ? "dollarsign" : "checkmark"
    }

    var body: some View {
        LogEntryCellButton(action: onTap) {
            HStack {
                Text(logEntry.logEntryDate, format: Date.FormatStyle(date: .long, time: .omitted))
                Spacer()
                if logEntry.attachments?.count ?? 0 > 0 {
                    Image(systemName: "paperclip")
                        .padding(.horizontal)
                }
            }
        } background: {
            LogEntryBackground(color: nil,
                               position: logEntry.isPurchase ? .end : .middle,
                               icon: icon)
        }
    }
}

#Preview {
    List {
        NextCheckCell(urgency: .now, onTap: {})
        LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: false), onTap: {})
        LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: false, hasAttachment: true), onTap: {})
        LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: true), onTap: {})
    }
    .listStyle(.insetGrouped)
}

#Preview {
    List {
        NextCheckCell(urgency: .soon(Date()), onTap: {})
        LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: true, hasAttachment: true), onTap: {})
    }
    .listStyle(.insetGrouped)
}

#Preview {
    List {
        NextCheckCell(urgency: .later(Date()), onTap: {})
        LogEntryCell(logEntry: CoreData.fakeLogEntry(isPurchase: false), onTap: {})
    }
    .listStyle(.insetGrouped)
}

#Preview {
    List {
        NextCheckCell(urgency: .never, onTap: {})
    }
    .listStyle(.insetGrouped)
}
