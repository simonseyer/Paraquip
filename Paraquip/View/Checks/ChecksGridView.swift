//
//  ChecksGridView.swift
//  Paraquip
//
//  Created by Simon Seyer on 17.09.23.
//

import SwiftUI

private extension CheckList {
    var rows: [[CheckSection]] {
        sections.chunked(by: 4)
    }

    var indexedRows: [(Int, [CheckSection])] {
        Array(zip(rows.indices, rows))
    }
}

private extension CheckSection {
    @ViewBuilder
    var titleText: some View {
        if let titleIcon {
            Text("\(Image(systemName: titleIcon)) \(title)")
        } else {
            Text(title)
        }
    }
}

struct ChecksGridView: View {
    let checks: CheckList

    var body: some View {
        Grid(horizontalSpacing: 30, verticalSpacing: 10) {
            ForEach(checks.indexedRows, id: \.0) { index, row in
                GridRow {
                    ForEach(row) { cell in
                        VStack {
                            HStack {
                                Spacer()
                                cell.titleText
                                    .imageScale(.small)
                                    .font(.system(size: 26, weight: .light))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 4)
                            }

                            ScrollView {
                                ForEach(cell.entries) { entry in
                                    Button(action: entry.onTap) {
                                        Label {
                                            Text(entry.name)
                                                .lineLimit(1)
                                            Spacer()
                                        } icon: {
                                            entry.checkUrgency.icon
                                                .frame(width: 25, height: 25)
                                                .background(
                                                    Circle()
                                                        .fill(entry.checkUrgency.color)
                                                )
                                                #if os(iOS)
                                                .foregroundStyle(.white)
                                                #endif
                                        }
                                    }
                                    .foregroundStyle(.primary)
                                    .buttonStyle(.bordered)
                                }
                            }
                            .scrollBounceBehavior(.basedOnSize)
                        }
                    }
                }

                if index < checks.rows.count - 1 {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 30)
    }
}

let previewData = CheckList(sections: [
    CheckSection(title: "Now", titleIcon: "hourglass", entries: [
        CheckEntry(id: UUID(),
                   name: "Explorer 2",
                   checkUrgency: .now,
                   onTap: {})
    ]),
    CheckSection(title: "Feb", entries: [
        CheckEntry(id: UUID(),
                   name: "Wani Light 2",
                   checkUrgency: .soon(.now),
                   onTap: {})]),
    CheckSection(title: "Mar", entries: []),
    CheckSection(title: "Apr", entries: []),
    CheckSection(title: "May", entries: [
        CheckEntry(id: UUID(),
                   name: "Iota 2",
                   checkUrgency: .later(.now),
                   onTap: {}),
        CheckEntry(id: UUID(),
                   name: "Angel SQ",
                   checkUrgency: .later(.now),
                   onTap: {}),
        CheckEntry(id: UUID(),
                   name: "Luna 2",
                   checkUrgency: .later(.now),
                   onTap: {})
    ]),
    CheckSection(title: "Jun", entries: []),
    CheckSection(title: "Jul", entries: []),
    CheckSection(title: "Aug", entries: []),
    CheckSection(title: "Sep", entries: []),
    CheckSection(title: "Oct", entries: []),
    CheckSection(title: "Nov", entries: []),
    CheckSection(title: "Later", titleIcon: "clock", entries: [
        CheckEntry(id: UUID(),
                   name: "Rise 4",
                   checkUrgency: .later(.now),
                   onTap: {})
    ]),

])

#Preview {
    NavigationStack {
        ChecksGridView(checks: previewData)
    }
}
