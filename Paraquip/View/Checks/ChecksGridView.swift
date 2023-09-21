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

    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var editLogEntryOperation: Operation<LogEntry>?

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
                                ForEach(cell.equipment) { equipment in
                                    ChecksGridButton(equipment: equipment) { logAction in
                                        switch logAction {
                                        case .create:
                                            let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                                            operation.object(for: equipment).addToCheckLog(operation.object)
                                            editLogEntryOperation = operation
                                        case .edit(let logEntry):
                                            editLogEntryOperation = Operation(editing: logEntry,
                                                                              withParentContext: managedObjectContext)
                                        }
                                    }
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
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationStack {
                LogEntryView(logEntry: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChecksGridView(checks: CheckList(equipment: CoreData.fakeProfile.allEquipment))
    }
}
