//
//  LogMenu.swift
//  Paraquip
//
//  Created by Simon Seyer on 21.09.23.
//

import SwiftUI

struct LogMenu: View {

    enum Action {
        case create
        case edit(LogEntry)
    }

    @ObservedObject var equipment: Equipment
    let action: (Action) -> Void

    @FetchRequest
    private var checkLog: FetchedResults<LogEntry>

    init(equipment: Equipment, action: @escaping (Action) -> Void) {
        self.equipment = equipment
        self.action = action
        _checkLog = FetchRequest<LogEntry>(sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
                                           predicate: NSPredicate(format: "%K == %@", #keyPath(LogEntry.equipment), equipment))
    }

    var body: some View {
        VStack(spacing: 0) {
            NextCheckButton(urgency: equipment.checkUrgency) {
                action(.create)
            }

            ForEach(checkLog) { logEntry in
                #if os(iOS)
                Divider()
                #endif
                LogEntryButton(logEntry: logEntry) {
                    action(.edit(logEntry))
                }
            }

            if let logEntry = equipment.purchaseLog {
                #if os(iOS)
                Divider()
                #endif
                LogEntryButton(logEntry: logEntry) {
                    action(.edit(logEntry))
                }
            }
        }
    }
}

#Preview {
    LogMenu(equipment: CoreData.fakeProfile.paraglider!) { _ in }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, .preview)
}
