//
//  LogEntryCell.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import CoreData

fileprivate let cellPadding = EdgeInsets(top: 13, leading: 36, bottom: 13, trailing: 0)

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
                .padding(.trailing, 12)
        }
        .padding(cellPadding)

        .listRowBackground(
            LogEntryCellBackground(color: urgency.color,
                                   position: .start,
                                   icon: nil as EmptyView?,
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

    @State private var previewedLogAttachment: URL?

    @ViewBuilder
    private var icon: some View {
        Group {
            if logEntry.isPurchase {
                Image(systemName: "dollarsign.circle")
                    .resizable()
            } else {
                Image(systemName: "checkmark.circle")
                    .resizable()
            }
        }
        .font(.system(size: 56.0, weight: .light))
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
                        .font(Font.body.weight(.medium))
                        .foregroundColor(.accentColor)
                }.buttonStyle(.bordered)
            }
        }
        .quickLookPreview($previewedLogAttachment, in: logEntry.attachmentURLs)
        .listRowBackground(
            LogEntryCellBackground(color: Color(UIColor.systemGray3),
                                   position: logEntry.isPurchase ? .end : .middle,
                                   icon: icon,
                                   isHighlighted: .constant(false))
        )
        .foregroundColor(.black)
    }
}


fileprivate struct LogEntryCellBackground<IconView: View>: View {

    enum Position {
        case start, middle, end
    }

    let color: Color
    let position: Position
    let icon: IconView?
    @Binding var isHighlighted: Bool

    private var circleDiameter: CGFloat {
        icon != nil ? 24 : 10
    }

    private var circleColor: Color {
        icon != nil ? Color(UIColor.systemGray6) : color
    }

    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .topLeading) {
                if isHighlighted {
                    Color(UIColor.systemGray4)
                } else {
                    Color.white
                }

                Rectangle()
                    .frame(
                        width: 2,
                        height: metrics.size.height * (position == .middle ? 1.0 : 0.5))
                    .foregroundColor(color)
                    .opacity(0.4)
                    .padding(EdgeInsets(top: metrics.size.height * (position == .start ? 0.5 : 0.0),
                                        leading: 30,
                                        bottom: 0,
                                        trailing: 0))

                Group {
                    Circle()
                        .frame(width: circleDiameter, height: circleDiameter)
                        .foregroundColor(circleColor)
                    if let icon = icon {
                        icon
                            .frame(width: circleDiameter, height: circleDiameter)
                            .foregroundColor(Color(UIColor.systemGray2))
                    }
                }
                .padding(EdgeInsets(top: metrics.size.height / 2 - (circleDiameter / 2),
                                    leading: 31 - (circleDiameter / 2.0),
                                    bottom: 0,
                                    trailing: 0))
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
            logEntry.addToAttachments(Attachment(context: CoreData.previewContext))
        }
        return logEntry
    }

    static var previews: some View {
        Group {
            List {
                NextCheckCell(urgency: .now, onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: false))
                LogEntryCell(logEntry: fakeEntry(isPurchase: false, hasAttachment: true))
                LogEntryCell(logEntry: fakeEntry(isPurchase: true))
            }
            .listStyle(.insetGrouped)
        }

        Group {
            List {
                NextCheckCell(urgency: .soon(Date()), onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: true, hasAttachment: true))
            }
            .listStyle(.insetGrouped)
        }

        Group {
            List {
                NextCheckCell(urgency: .later(Date()), onTap: {})
                LogEntryCell(logEntry: fakeEntry(isPurchase: false))
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
