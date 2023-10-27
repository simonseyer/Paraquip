//
//  LogEntryButton.swift
//  Paraquip
//
//  Created by Simon Seyer on 21.09.23.
//

import SwiftUI

private struct BaseLogEntryButton<Content: View, Background: View>: View {

    let action: () -> Void
    let content: () -> Content
    let background: () -> Background

    var body: some View {
        Button(action: action) {
            content()
            .padding(.leading, 70)
            .frame(height: 70)
            .padding(.trailing, 34)
        }
        #if os(visionOS)
        .buttonStyle(.plain)
        #else
        .foregroundStyle(.primary)
        #endif
        .buttonBorderShape(.roundedRectangle(radius: 0))
        .clipShape(Rectangle())
        .background(alignment: .leading) {
            background()
        }
    }
}

struct NextCheckButton: View {

    let urgency: Equipment.CheckUrgency
    let action: () -> Void

    var body: some View {
        BaseLogEntryButton(action: action) {
            HStack {
                Text(urgency.formattedCheckInterval)
                Spacer()
                Image(systemName: "square.and.pencil")
                    .padding(.leading, 40)
            }
        } background: {
            LogEntryBackground(color: urgency.color,
                               position: .start,
                               icon: nil)
        }
    }
}

struct LogEntryButton: View {

    @ObservedObject var logEntry: LogEntry
    let action: () -> Void

    private var icon: String {
        logEntry.isPurchase ? "dollarsign" : "checkmark"
    }

    var body: some View {
        BaseLogEntryButton(action: action) {
            HStack {
                Text(logEntry.logEntryDate,
                     format: Date.FormatStyle(date: .long, time: .omitted))

                Spacer()
                if logEntry.attachments?.count ?? 0 > 0 {
                    Image(systemName: "paperclip")
                        .padding(.leading, 40)
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
    VStack(spacing: 0) {
        NextCheckButton(urgency: .now, action: {})
        LogEntryButton(logEntry: CoreData.fakeLogEntry(isPurchase: false), action: {})
        LogEntryButton(logEntry: CoreData.fakeLogEntry(isPurchase: false, hasAttachment: true), action: {})
        LogEntryButton(logEntry: CoreData.fakeLogEntry(isPurchase: true), action: {})
    }
}
