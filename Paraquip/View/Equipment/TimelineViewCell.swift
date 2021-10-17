//
//  TimelineViewCell.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI
import CoreData

extension TimelineEntry: Identifiable {
    private static let purchaseID = UUID()
    private static let nextCheckID = UUID()

    var id: UUID {
        switch self {
        case .purchase:
            return Self.purchaseID
        case .check(let check):
            return check.id!
        case .nextCheck:
            return Self.nextCheckID
        }
    }

    var isCheck: Bool {
        if case .check = self {
            return true
        } else {
            return false
        }
    }
}

fileprivate extension TimelineEntry {
    var lineHeightFactor: CGFloat {
        switch self {
        case .purchase, .nextCheck:
            return 0.5
        case .check:
            return 1.0
        }
    }

    var lineTopPaddingFactor: CGFloat {
        if case .nextCheck = self {
            return 0.5
        } else {
            return 0.0
        }
    }

    var color: Color {
        switch self {
        case .purchase, .check:
            return Color(UIColor.systemGray3)
        case .nextCheck(let urgency):
            return urgency.color
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    var text: LocalizedStringKey {
        switch self {
        case .purchase(let date):
            return LocalizedStringKey(Self.dateFormatter.string(from: date))
        case .check(let check):
            return LocalizedStringKey(Self.dateFormatter.string(from: check.date!))
        case .nextCheck(let urgency):
            return urgency.formattedCheckInterval
        }
    }
}

struct TimelineViewCell: View {

    let timelineEntry: TimelineEntry
    let logAction: () -> Void

    @State private var isHighlighted = false

    var body: some View {
        HStack {
            Text(timelineEntry.text)
            Spacer()
            if timelineEntry.isNextCheck {
                Image(systemName: "square.and.pencil")
                    .font(Font.body.weight(.medium))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(EdgeInsets(top: 13,
                            leading: 36,
                            bottom: 13,
                            trailing: 0))

        .listRowBackground(
            TimelineVisual(timelineEntry: timelineEntry, isHighlighted: $isHighlighted)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if timelineEntry.isNextCheck {
                logAction()
            }
        }
        .simultaneousGesture(
            timelineEntry.isNextCheck ?
            DragGesture(minimumDistance: 0.0)
                .onChanged { _ in isHighlighted = true }
                .onEnded { _ in isHighlighted = false }
            : nil
        )
    }
}

struct TimelineVisual: View {

    let timelineEntry: TimelineEntry
    @Binding var isHighlighted: Bool

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
                        height: metrics.size.height * timelineEntry.lineHeightFactor)
                    .foregroundColor(timelineEntry.color)
                    .opacity(0.4)
                    .padding(EdgeInsets(top: metrics.size.height * timelineEntry.lineTopPaddingFactor, leading: 4, bottom: 0, trailing: 0))
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(timelineEntry.color)
                    .padding(.top, metrics.size.height / 2 - 5)
                }
                .padding(.leading, 27)
            }
        }

    }
}

struct TimelineView_Previews: PreviewProvider {

    static let timelines: [[TimelineEntry]] = [
        [
            .nextCheck(urgency: .now),
            .check(check: Check.create(context: CoreData.previewContext, date: Date())),
            .check(check: Check.create(context: CoreData.previewContext, date: Date())),
            .purchase(date: Date())
        ],
        [
            .nextCheck(urgency: .soon(Date())),
            .purchase(date: Date())
        ],
        [
            .nextCheck(urgency: .later(Date())),
            .check(check: Check.create(context: CoreData.previewContext, date: Date())),
        ],
        [
            .nextCheck(urgency: .never),
        ],
    ]
    static var previews: some View {
        ForEach(Array(zip(timelines.indices, timelines)), id: \.0) { (_, timeline) in
            Group {
                List {
                    ForEach(timeline) { timelineEntry in
                        TimelineViewCell(timelineEntry: timelineEntry, logAction: {})
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}
