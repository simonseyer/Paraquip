//
//  LogEntryView.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI

struct LogEntryView: View {

    @ObservedObject var logEntry: LogEntry

    var body: some View {
        Form {
            DatePicker("", selection: $logEntry.logEntryDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
    }
}

struct LogEntryView_Previews: PreviewProvider {
    static var previews: some View {
        LogEntryView(logEntry: LogEntry.create(context: CoreData.previewContext))
    }
}
