//
//  LogSheet.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData

struct LogSheet: View {

    @ObservedObject var equipment: Equipment
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var editLogEntryOperation: Operation<LogEntry>?

    @FetchRequest
    private var checkLog: FetchedResults<LogEntry>

    init(equipment: Equipment) {
        self.equipment = equipment
        _checkLog = FetchRequest<LogEntry>(sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
                                           predicate: NSPredicate(format: "%K == %@", #keyPath(LogEntry.equipment), equipment))
    }

    var body: some View {
        List {
            NextCheckCell(urgency: equipment.checkUrgency) {
                let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                operation.object(for: equipment).addToCheckLog(operation.object)
                editLogEntryOperation = operation
            }
            ForEach(checkLog) { logEntry in
                LogEntryCell(logEntry: logEntry) {
                    editLogEntry(logEntry)
                }
            }
            if let logEntry = equipment.purchaseLog {
                LogEntryCell(logEntry: logEntry) {
                    editLogEntry(logEntry)
                }
            }
        }
        .navigationTitle("\(equipment.brandName) \(equipment.equipmentName)")
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationStack {
                LogEntryView(logEntry: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
    }

    private func editLogEntry(_ logEntry: LogEntry) {
        editLogEntryOperation = Operation(editing: logEntry,
                                          withParentContext: managedObjectContext)
    }
}

#Preview {
    NavigationStack {
        LogSheet(equipment: CoreData.fakeProfile.paraglider!)
    }
    .environment(\.locale, .init(identifier: "de"))
    .environment(\.managedObjectContext, .preview)
}
