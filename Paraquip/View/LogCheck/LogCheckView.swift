//
//  LogCheckView.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.06.21.
//

import SwiftUI

struct LogCheckView: View {

    @ObservedObject var check: Check

    var body: some View {
        Form {
            DatePicker("", selection: $check.checkDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
        }
    }
}

struct LogCheckView_Previews: PreviewProvider {
    static var previews: some View {
        LogCheckView(check: Check.create(context: CoreData.previewContext))
    }
}
